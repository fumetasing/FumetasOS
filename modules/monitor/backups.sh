#!/bin/bash

###########################################################
# FumetaOS
# Monitor de copias de seguridad
###########################################################

ERROR=0

ultima_ejecucion()
{
    SERVICE="$1"

    LAST=$(systemctl show "$SERVICE" \
        -p ExecMainExitTimestamp \
        --value 2>/dev/null)

    if [ -z "$LAST" ] || [ "$LAST" = "n/a" ]; then
        LAST=$(systemctl show "$SERVICE" \
            -p InactiveExitTimestamp \
            --value 2>/dev/null)
    fi

    echo "$LAST"
}

proxima_ejecucion()
{
    systemctl show "$1" \
        -p NextElapseUSecRealtime \
        --value 2>/dev/null
}

mostrar_copia_programada()
{
    SERVICE="$1"
    TIMER="$2"
    LABEL="$3"

    if ! systemctl cat "$SERVICE" >/dev/null 2>&1 ||
        ! systemctl cat "$TIMER" >/dev/null 2>&1
    then
        echo "🔴 $LABEL"
        echo "   Servicio o temporizador no instalado"
        ERROR=20
        return
    fi

    RESULT=$(systemctl show "$SERVICE" -p Result --value 2>/dev/null)
    LAST=$(ultima_ejecucion "$SERVICE")
    NEXT=$(proxima_ejecucion "$TIMER")

    if ! systemctl is-active --quiet "$TIMER"; then
        echo "🔴 $LABEL"
        echo "   Temporizador inactivo"
        ERROR=20
        return
    fi

    case "$RESULT" in
        success)
            echo "✅ $LABEL"
            echo "   Última: ${LAST:-completada}"
            echo "   Próxima: ${NEXT:-No programada}"
            ;;
        failed|exit-code|signal|timeout)
            echo "🔴 $LABEL"
            echo "   Última: ${LAST:-sin fecha disponible}"
            echo "   Resultado: $RESULT"
            echo "   Próxima: ${NEXT:-No programada}"
            ERROR=20
            ;;
        *)
            echo "🟡 $LABEL"
            echo "   Última: todavía no se ha completado ninguna ejecución"
            echo "   Próxima: ${NEXT:-No programada}"
            ERROR=10
            ;;
    esac
}

mostrar_copia_encadenada()
{
    SERVICE="$1"
    PREDECESOR="$2"
    LABEL="$3"

    RESULT=$(systemctl show "$SERVICE" -p Result --value 2>/dev/null)
    LAST=$(ultima_ejecucion "$SERVICE")

    case "$RESULT" in
        success)
            echo "✅ $LABEL"
            echo "   Última: ${LAST:-completada}"
            echo "   Próxima: al terminar $PREDECESOR"
            ;;
        failed|exit-code|signal|timeout)
            echo "🔴 $LABEL"
            echo "   Última: ${LAST:-sin fecha disponible}"
            echo "   Resultado: $RESULT"
            echo "   Próxima: al terminar $PREDECESOR"
            ERROR=20
            ;;
        *)
            echo "🟡 $LABEL"
            echo "   Última: pendiente de la primera ejecución"
            echo "   Próxima: al terminar $PREDECESOR"
            ERROR=10
            ;;
    esac
}

echo

mostrar_copia_programada \
    "fumetaos-timecapsule-mac-backup.service" \
    "fumetaos-timecapsule-mac-backup.timer" \
    "Time Capsule → Mac"

echo

mostrar_copia_encadenada \
    "fumetaos-mac-backup.service" \
    "Time Capsule → Mac" \
    "Espejo general al Mac"

echo

mostrar_copia_programada \
    "fumetaos-recovery-backup.service" \
    "fumetaos-recovery-backup.timer" \
    "Recuperación cifrada"

echo

mostrar_copia_programada \
    "fumetaos-recovery-verify.service" \
    "fumetaos-recovery-verify.timer" \
    "Verificación cifrada"

exit "$ERROR"
