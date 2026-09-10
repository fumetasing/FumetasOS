#!/bin/bash

###########################################################
# FumetaOS - Monitor de copias (solo consulta)
###########################################################

ERROR=0
NOW=$(date +%s)
DAILY_LIMIT=$((30 * 3600))
WEEKLY_LIMIT=$((8 * 24 * 3600))
TC="fumetaos-timecapsule-mac-backup.service"
GENERAL="fumetaos-mac-backup.service"
TC_TIMER="fumetaos-timecapsule-mac-backup.timer"

elevar_error()
{
    if [ "$1" -gt "$ERROR" ]; then ERROR="$1"; fi
}

propiedad()
{
    timeout 5 systemctl show "$1" -p "$2" --value 2>/dev/null
}

# Eventos del gestor systemd, no mensajes impresos por los scripts.
# No se limita al arranque actual. Se consultan los últimos 30 días.
ultimo_evento()
{
    local unit="$1" output
    shift

    if ! output=$(timeout 5 journalctl --quiet --no-pager \
        --since="30 days ago" -n 1 -o short-unix \
        _PID=1 "UNIT=$unit" "$@" 2>/dev/null); then
        return 1
    fi

    printf '%s\n' "$output" | awk '
        $1 ~ /^[0-9]+\.[0-9]+$/ {
            split($1, parts, ".")
            printf "%s%06d\n", parts[1], parts[2]
            exit
        }'
}

UNITS=(
    "$TC"
    "$GENERAL"
    fumetaos-recovery-backup.service
    fumetaos-recovery-verify.service
)

declare -a STATE RESULT LOADED OK BAD HISTORY

leer_servicio()
{
    local idx="$1" unit="${UNITS[$1]}"

    LOADED[$idx]=$(propiedad "$unit" LoadState)
    STATE[$idx]=$(propiedad "$unit" ActiveState)
    RESULT[$idx]=$(propiedad "$unit" Result)
    HISTORY[$idx]=1

    OK[$idx]=$(ultimo_evento "$unit" \
        MESSAGE_ID=39f53479d3a045ac8e11786248231fbf) ||
        HISTORY[$idx]=0

    BAD[$idx]=$(ultimo_evento "$unit" \
        MESSAGE_ID=be02cf6855d2428ba40df7e9d022f03d \
        MESSAGE_ID=d9b373ed55a64feb8242e02dbe79a49c) ||
        HISTORY[$idx]=0
}

en_curso()
{
    case "${STATE[$1]}" in
        activating|active|reloading|deactivating)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

ha_fallado()
{
    local idx="$1"

    [ "${STATE[$idx]}" = failed ] && return 0

    case "${RESULT[$idx]}" in
        ""|success)
            ;;
        *)
            return 0
            ;;
    esac

    [ "${BAD[$idx]:-0}" -gt "${OK[$idx]:-0}" ]
}

mostrar_usb()
{
    local output free used

    if ! output=$(timeout 25 ssh \
        -i /home/server/.ssh/id_ed25519_fumetaos_mac \
        -o BatchMode=yes \
        -o ConnectTimeout=10 \
        -o ServerAliveInterval=5 \
        -o ServerAliveCountMax=2 \
        -o UserKnownHostsFile=/home/server/.ssh/known_hosts \
        -o StrictHostKeyChecking=yes \
        fumetasing@192.168.1.5 /bin/sh -s 2>/dev/null <<'REMOTE'
TARGET="/Users/fumetasing/FumetaOS-Server"

[ -d "$TARGET" ] || exit 20

df -h "$TARGET" |
    awk 'NR == 2 { print $4 "|" $5 }'
REMOTE
    ); then
        echo "🔴 USB del Mac"
        echo "   No disponible o no se pudo consultar"
        elevar_error 20
        return
    fi

    IFS='|' read -r free used <<< "$output"

    if [[ -z "$free" || ! "$used" =~ ^[0-9]+%$ ]]; then
        echo "🔴 USB del Mac"
        echo "   No se pudo interpretar el espacio disponible"
        elevar_error 20
        return
    fi

    echo "🟢 USB del Mac"
    echo "   Libre: $free"
    echo "   Uso: $used"
}

mostrar_copia()
{
    local idx="$1" unit="${UNITS[$1]}"
    local timer="$2" label="$3" limit="$4"
    local level=0 icon="✅" detail=""
    local next last age=0 chain

    next=$(propiedad "$timer" NextElapseUSecRealtime)

    case "$next" in
        ""|n/a)
            next="No programada"
            ;;
    esac

    last="No consta en el registro accesible de los últimos 30 días"

    if [ "${OK[$idx]:-0}" -gt 0 ]; then
        last=$(date \
            -d "@$((OK[$idx] / 1000000))" \
            '+%d/%m/%Y %H:%M:%S %Z')

        age=$((NOW - OK[$idx] / 1000000))
    fi

    if [ "${LOADED[$idx]}" != loaded ]; then
        level=20
        detail="Servicio no disponible"

    elif en_curso "$idx"; then
        level=10
        detail="En curso; todavía no ha terminado"

    elif ha_fallado "$idx"; then
        level=20
        detail="Última ejecución fallida (ver registro del servicio)"

    elif [ "${HISTORY[$idx]}" != 1 ]; then
        level=10
        detail="No se pudo consultar todo el historial; estado no confirmado"

    elif [ "${OK[$idx]:-0}" -eq 0 ]; then
        level=10
        detail="No se puede confirmar una ejecución correcta"
    fi

    if [ "${OK[$idx]:-0}" -gt 0 ]; then
        if [ "$age" -lt 0 ]; then
            [ "$level" -lt 10 ] && level=10
            detail="${detail:+$detail. }Fecha futura: revisar el reloj"

        elif [ "$age" -gt "$limit" ]; then
            level=20
            detail="${detail:+$detail. }Atrasada: $((age / 3600)) h sin completar; límite $((limit / 3600)) h"
        fi
    fi

    if [ "$(propiedad "$timer" ActiveState)" != active ]; then
        level=20
        detail="${detail:+$detail. }Temporizador inactivo o no disponible"

    elif [ "$next" = "No programada" ]; then
        [ "$level" -lt 10 ] && level=10
        detail="${detail:+$detail. }Sin próxima fecha disponible"
    fi

    if [ "$unit" = "$GENERAL" ]; then
        next="Al terminar Time Capsule → Mac (programada: $next)"
        chain=$(propiedad "$TC" OnSuccess)

        case " $chain " in
            *" $GENERAL "*)
                ;;
            *)
                level=20
                detail="${detail:+$detail. }Enlace automático de la cadena no configurado"
                ;;
        esac

        if ! en_curso "$idx"; then
            if en_curso 0; then
                [ "$level" -lt 10 ] && level=10
                detail="${detail:+$detail. }Esperando a que termine Time Capsule"

            elif [ "${LOADED[0]}" != loaded ] || ha_fallado 0; then
                level=20
                detail="${detail:+$detail. }Cadena bloqueada por Time Capsule"
            fi
        fi
    fi

    case "$level" in
        10)
            icon="🟡"
            ;;
        20)
            icon="🔴"
            ;;
    esac

    echo "$icon $label"
    echo "   Última correcta: $last"
    [ -z "$detail" ] || echo "   Estado: $detail"
    echo "   Próxima: $next"

    elevar_error "$level"
}

for idx in "${!UNITS[@]}"
do
    leer_servicio "$idx"
done

echo
mostrar_usb

echo
mostrar_copia \
    0 \
    "$TC_TIMER" \
    "Time Capsule → Mac" \
    "$DAILY_LIMIT"

echo
mostrar_copia \
    1 \
    "$TC_TIMER" \
    "Espejo general al Mac" \
    "$DAILY_LIMIT"

echo
mostrar_copia \
    2 \
    fumetaos-recovery-backup.timer \
    "Recuperación cifrada y máquinas virtuales" \
    "$DAILY_LIMIT"

echo
mostrar_copia \
    3 \
    fumetaos-recovery-verify.timer \
    "Verificación cifrada" \
    "$WEEKLY_LIMIT"

exit "$ERROR"
