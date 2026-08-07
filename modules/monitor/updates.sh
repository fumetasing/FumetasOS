#!/bin/bash

###########################################################
# FumetaOS
# Monitor de actualizaciones
###########################################################

WATCH=0

if [ "$1" = "--watch" ]; then
    WATCH=1
fi

UPDATES=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)

if [ "$UPDATES" -eq 0 ]; then

    if [ "$WATCH" -eq 0 ]; then
        echo "🟢 Sistema actualizado"
    fi

    exit 0

elif [ "$UPDATES" -lt 50 ]; then

    if [ "$WATCH" -eq 0 ]; then
        echo "🟡 $UPDATES actualizaciones disponibles"
    else
        echo "$UPDATES actualizaciones disponibles"
    fi

    exit 10

else

    if [ "$WATCH" -eq 0 ]; then
        echo "🔴 $UPDATES actualizaciones disponibles"
    else
        echo "$UPDATES actualizaciones disponibles"
    fi

    exit 20

fi
