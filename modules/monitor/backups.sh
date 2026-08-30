#!/bin/bash

###########################################################
# FumetaOS
# Monitor de copias de seguridad
###########################################################

ERROR=0

mostrar_copia()
{
    SERVICE="$1"
    TIMER="$2"
    LABEL="$3"

    if ! systemctl cat "$SERVICE" >/dev/null 2>&1 ||
        ! systemctl cat "$TIMER" >/dev/null 2>&1
    then
        echo "🔴 $LABEL"
        echo "   Servicio o timer no instalado"
        ERROR=20
        return
    fi

    RESULT=$(systemctl show "$SERVICE" -p Result --value 2>/dev/null)
    LAST=$(systemctl show "$SERVICE" \
        -p ExecMainExitTimestamp \
        --value 2>/dev/null)
    NEXT=$(systemctl show "$TIMER" \
        -p NextElapseUSecRealtime \
        --value 2>/dev/null)

    if [ -z "$NEXT" ] || [ "$NEXT" = "n/a" ]
    then
        NEXT="No programada"
        ERROR=20
    fi

    if [ -z "$LAST" ] || [ "$LAST" = "n/a" ]
    then
        echo "🟡 $LABEL"
        echo "   Última: todavía no se ha completado ninguna ejecución"
        echo "   Próxima: $NEXT"
        ERROR=10
        return
    fi

    case "$RESULT" in
        success)
            echo "✅ $LABEL"
            echo "   Última: $LAST"
            echo "   Próxima: $NEXT"
            ;;
        *)
            echo "🔴 $LABEL"
            echo "   Última: $LAST"
            echo "   Resultado: ${RESULT:-desconocido}"
            echo "   Próxima: $NEXT"
            ERROR=20
            ;;
    esac
}

echo

mostrar_copia \
    "fumetaos-mac-backup.service" \
    "fumetaos-mac-backup.timer" \
    "Espejo al Mac"

echo

mostrar_copia \
    "fumetaos-recovery-backup.service" \
    "fumetaos-recovery-backup.timer" \
    "Recuperación cifrada"

echo

mostrar_copia \
    "fumetaos-recovery-verify.service" \
    "fumetaos-recovery-verify.timer" \
    "Verificación cifrada"

exit "$ERROR"
