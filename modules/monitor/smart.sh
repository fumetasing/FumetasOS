#!/bin/bash

###########################################################
# FumetaOS
# Módulo SMART
###########################################################

source /opt/fumetaos/core/common.sh

WATCH=0

[ "$1" = "--watch" ] && WATCH=1

ERROR=0

for DISK in "$HDD_DEVICE" "$SSD_DEVICE"
do

    NAME=$(disk_name "$DISK")

    SALIDA=$(smartctl_cmd -H "$DISK" 2>/dev/null)
    RET=$?

    if [ "$RET" -ne 0 ]; then

        if [ "$WATCH" -eq 0 ]; then
            echo "⚠️ $NAME (no se ha podido comprobar)"
        else
            echo "No se ha podido comprobar SMART de $NAME"
        fi

        [ "$ERROR" -lt 10 ] && ERROR=10
        continue

    fi

    if echo "$SALIDA" | grep -q "PASSED"; then

        if [ "$WATCH" -eq 0 ]; then
            echo "✅ $NAME"
        fi

    else

        if [ "$WATCH" -eq 0 ]; then
            echo "🚨 $NAME"
        else
            echo "Problema SMART en $NAME"
        fi

        ERROR=20

    fi

done

exit "$ERROR"
