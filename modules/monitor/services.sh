#!/bin/bash

###########################################################
# FumetaOS
# Monitor de servicios
###########################################################

WATCH=0

if [ "$1" = "--watch" ]; then
    WATCH=1
fi

ERROR=0

SERVICES=(
    casaos
    docker
    tailscaled
    noip-duc
    ssh
)

for SERVICE in "${SERVICES[@]}"
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
