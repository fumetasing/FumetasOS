#!/bin/bash

###########################################################
# FumetaOS
# Monitor de memoria
###########################################################

source /opt/fumetaos/core/common.sh
source /opt/fumetaos/core/system.sh

WATCH=0

if [ "$1" = "--watch" ]; then
    WATCH=1
fi

USO=$(ram_usage)
MEMORIA="$(ram_used) / $(ram_total)"

if [ "$USO" -lt "$RAM_WARNING" ]; then

    if [ "$WATCH" -eq 0 ]; then
        echo "🟢 Uso: ${USO}%"
        echo "   $MEMORIA"
    fi

    exit 0

elif [ "$USO" -lt "$RAM_CRITICAL" ]; then

    if [ "$WATCH" -eq 0 ]; then
        echo "🟡 Uso: ${USO}%"
        echo "   $MEMORIA"
    else
        echo "RAM al ${USO}%"
    fi

    exit 10

else

    if [ "$WATCH" -eq 0 ]; then
        echo "🔴 Uso: ${USO}%"
        echo "   $MEMORIA"
    else
        echo "RAM al ${USO}%"
    fi

    exit 20

fi
