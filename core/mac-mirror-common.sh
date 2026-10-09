#!/bin/bash

###########################################################
# FumetaOS
# Utilidades compartidas para copias espejo al Mac
###########################################################

mac_mirror_enviar_telegram() {
	local message="$1"

	if [ ! -x "$TELEGRAM_NOTIFY" ]; then
		echo "⚠️ No se puede enviar Telegram: falta $TELEGRAM_NOTIFY"
		return 0
	fi

	if ! printf '%s\n' "$message" | "$TELEGRAM_NOTIFY"; then
		echo "⚠️ No se pudo enviar la notificación de Telegram"
	fi
}

mac_mirror_crear_ssh_command() {
	SSH_COMMAND=(
		ssh
		-i "$SSH_KEY"
		-o BatchMode=yes
		-o ConnectTimeout=20
		-o ServerAliveInterval=30
		-o ServerAliveCountMax=6
		-o "UserKnownHostsFile=$SSH_KNOWN_HOSTS"
		-o StrictHostKeyChecking=yes
	)

	printf -v RSYNC_SSH_COMMAND '%q ' "${SSH_COMMAND[@]}"
	RSYNC_SSH_COMMAND="${RSYNC_SSH_COMMAND% }"

	RSYNC_DELETE_OPTIONS=(
		-a
		--no-owner
		--no-group
		--dry-run
		--delete-delay
		--itemize-changes
		--out-format='%i'
		--rsync-path=/opt/homebrew/bin/rsync
		--protect-args
	)

	RSYNC_COPY_OPTIONS=(
		-a
		--no-owner
		--no-group
		--delete-delay
		--partial
		--human-readable
		--stats
		--rsync-path=/opt/homebrew/bin/rsync
		--protect-args
		--progress
	)
}

mac_mirror_usb_disponible() {
	local remote_script

	remote_script="$(
		{
			printf 'ROOT=%q\n' "$MAC_ROOT"
			printf 'EXPECTED_MOUNT=%q\n' "$MAC_USB_MOUNT"
			printf 'MINIMUM_FREE_KB=%q\n' "$MINIMUM_FREE_KB"

			cat <<'REMOTE'
punto_montaje()
{
    df -P "$1" |
        awk 'NR == 2 { sub(/^.* [0-9][0-9]*%[[:space:]]*/, ""); print }'
}

mount_point="$(punto_montaje "$ROOT")"

if [ -z "$mount_point" ]; then
    echo "No se pudo obtener el punto de montaje del destino: $ROOT" >&2
    exit 20
fi

if [ "$mount_point" != "$EXPECTED_MOUNT" ]; then
    echo "El destino está en $mount_point; se esperaba $EXPECTED_MOUNT" >&2
    exit 20
fi

available_kb="$(df -Pk "$ROOT" | awk 'NR == 2 { print $4 }')"

case "$available_kb" in
    ''|*[!0-9]*)
        echo "No se pudo obtener el espacio libre del USB" >&2
        exit 20
        ;;
esac

if [ "$available_kb" -lt "$MINIMUM_FREE_KB" ]; then
    echo "El USB tiene menos de 50 GiB libres" >&2
    exit 20
fi

if [ ! -r "$ROOT" ] || [ ! -w "$ROOT" ] || [ ! -x "$ROOT" ]; then
    echo "El destino del USB no tiene permisos suficientes: $ROOT" >&2
    exit 20
fi

echo "💾 USB validado: $EXPECTED_MOUNT"
REMOTE
		}
	)"

	mac_mirror_ssh_comprobar \
		"$MAC_USER@$MAC_HOST" \
		/bin/sh -s <<<"$remote_script"
}

mac_mirror_contar_borrados() {
	local source_dir="$1"
	local rsync_destination="$2"

	shift 2

	rsync \
		"${RSYNC_DELETE_OPTIONS[@]}" \
		"$@" \
		-e "$RSYNC_SSH_COMMAND" \
		"$source_dir" \
		"$rsync_destination" |
		awk '$1 == "*deleting" || $1 == "deleting" { count++ } END { print count + 0 }'
}

mac_mirror_copiar() {
	local source_dir="$1"
	local rsync_destination="$2"

	shift 2

	rsync \
		"${RSYNC_COPY_OPTIONS[@]}" \
		"$@" \
		"${DRY_RUN[@]}" \
		-e "$RSYNC_SSH_COMMAND" \
		"$source_dir" \
		"$rsync_destination"
}

# La sesión solo se activa explícitamente en la copia Time Capsule -> Mac.
mac_mirror_cerrar_sesion() {
	if [ "${MAC_SESSION_FD_OPEN:-0}" -eq 1 ]; then
		exec 8>&-
		MAC_SESSION_FD_OPEN=0
	fi
	if [ -n "${MAC_SESSION_PID:-}" ]; then
		if kill -0 "$MAC_SESSION_PID" 2>/dev/null; then
			kill "$MAC_SESSION_PID" 2>/dev/null || true
		fi
		wait "$MAC_SESSION_PID" 2>/dev/null || true
		MAC_SESSION_PID=""
	fi
	# Solo el directorio privado que creó esta ejecución; nunca datos del Mac.
	if [ -n "${MAC_SESSION_DIR:-}" ] && [ -d "$MAC_SESSION_DIR" ]; then
		rm -f -- "$MAC_SESSION_DIR/entrada" "$MAC_SESSION_DIR/listo" \
			"$MAC_SESSION_DIR/error" "$MAC_SESSION_DIR/control"
		rmdir -- "$MAC_SESSION_DIR" 2>/dev/null || true
		MAC_SESSION_DIR=""
	fi
}

mac_mirror_abrir_sesion() {
	local attempt=1 tick remote_command
	local base_ssh=("${SSH_COMMAND[@]}")
	remote_command="/usr/bin/caffeinate -i -s /bin/sh -c 'printf \"FUMETAOS_MAC_DESPIERTO\\n\"; exec /bin/cat >/dev/null'"
	while [ "$attempt" -le 3 ]; do
		MAC_SESSION_DIR="$(mktemp -d /run/fumetaos-mac-session.XXXXXXXX)" || return 20
		chmod 700 "$MAC_SESSION_DIR"
		mkfifo -m 600 "$MAC_SESSION_DIR/entrada"
		exec 8<>"$MAC_SESSION_DIR/entrada"
		MAC_SESSION_FD_OPEN=1
		SSH_COMMAND=("${base_ssh[@]}" -o "ControlPath=$MAC_SESSION_DIR/control")
		(
			exec 8>&-
			exec "${SSH_COMMAND[@]}" -T -o ControlMaster=yes -o ControlPersist=no \
				"$MAC_USER@$MAC_HOST" "$remote_command" <"$MAC_SESSION_DIR/entrada"
		) >"$MAC_SESSION_DIR/listo" 2>"$MAC_SESSION_DIR/error" &
		MAC_SESSION_PID=$!
		tick=0
		while [ "$tick" -lt 45 ]; do
			if grep -qx 'FUMETAOS_MAC_DESPIERTO' "$MAC_SESSION_DIR/listo" &&
				[ -S "$MAC_SESSION_DIR/control" ] && kill -0 "$MAC_SESSION_PID" 2>/dev/null; then
				printf -v RSYNC_SSH_COMMAND '%q ' "${SSH_COMMAND[@]}"
				RSYNC_SSH_COMMAND="${RSYNC_SSH_COMMAND% }"
				echo "✅ Sesión SSH persistente y protección temporal contra reposo iniciadas."
				return 0
			fi
			kill -0 "$MAC_SESSION_PID" 2>/dev/null || break
			sleep 1
			tick=$((tick + 1))
		done
		mac_mirror_cerrar_sesion
		SSH_COMMAND=("${base_ssh[@]}")
		if [ "$attempt" -lt 3 ]; then
			echo "⚠️ El Mac no confirmó la sesión; nuevo intento en 15 segundos."
			sleep 15
		fi
		attempt=$((attempt + 1))
	done
	echo "❌ No se pudo establecer la sesión protegida con el Mac; no se inicia la copia."
	return 255
}

mac_mirror_ssh_comprobar() {
	local attempt=1 status=0 maximum="${MAC_SSH_CHECK_RETRIES:-1}"
	while [ "$attempt" -le "$maximum" ]; do
		if [ -n "${MAC_SESSION_PID:-}" ] && ! kill -0 "$MAC_SESSION_PID" 2>/dev/null; then
			echo "❌ Se perdió la sesión que mantiene despierto el Mac." >&2
			return 255
		fi
		if "${SSH_COMMAND[@]}" "$@"; then
			return 0
		else
			status=$?
		fi
		# Nunca tratar un error remoto de disco/carpeta como un error de red.
		[ "$status" -eq 255 ] || return "$status"
		[ "$attempt" -lt "$maximum" ] || return "$status"
		echo "⚠️ Falló la conexión SSH de comprobación; reintento en 15 segundos." >&2
		sleep 15
		attempt=$((attempt + 1))
	done
	return "$status"
}
