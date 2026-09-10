#!/bin/bash

###########################################################

# FumetaOS

# Monitor de servicios

###########################################################

source "$(dirname "$0")/../../core/common.sh"


WATCH=0

if [ "$1" = "--watch" ]; then
WATCH=1
fi


ERROR=0


for SERVICE in $SYSTEM_SERVICES
do


if systemctl is-active --quiet "$SERVICE"; then

    if [ "$WATCH" -eq 0 ]; then
        echo "✅ $SERVICE"
    fi


else

    if [ "$WATCH" -eq 0 ]; then
        echo "🚨 $SERVICE"
    else
        echo "Servicio detenido: $SERVICE"
    fi

    ERROR=20

fi


done


exit $ERROR
