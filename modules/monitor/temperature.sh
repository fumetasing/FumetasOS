#!/bin/bash

###########################################################
# FumetaOS
# Monitor de temperatura
###########################################################

source /opt/fumetaos/core/common.sh

WATCH=0

if [ "$1" = "--watch" ]; then
    WATCH=1
fi

TEMP=$(sensors | awk '/Package id 0:/ {gsub("\\+|°C","",$4); print int($4)}')

if [ -z "$TEMP" ]; then

    [ "$WATCH" -eq 0 ] && echo "❓ No se pudo leer la temperatura"

    exit 20

fi

if [ "$TEMP" -lt "$CPU_WARNING" ]; then

    [ "$WATCH" -eq 0 ] && echo "🌡️ CPU: ${TEMP}°C 🟢"

    exit 0

elif [ "$TEMP" -lt "$CPU_CRITICAL" ]; then

    if [ "$WATCH" -eq 0 ]; then
        echo "🌡️ CPU: ${TEMP}°C 🟡"
    else
        echo "CPU a ${TEMP}°C"
    fi

    exit 10

else

    if [ "$WATCH" -eq 0 ]; then
        echo "🌡️ CPU: ${TEMP}°C 🔴"
    else
        echo "CPU a ${TEMP}°C"
    fi

    exit 20

fi
