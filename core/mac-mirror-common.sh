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

	"${SSH_COMMAND[@]}" \
		"$MAC_USER@$MAC_HOST" \
		/bin/sh -s <<<"$remote_script"
}
