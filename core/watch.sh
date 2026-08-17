#!/bin/bash

###########################################################
# FumetaOS
# Watch Core
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/system.sh"
source "$(dirname "${BASH_SOURCE[0]}")/apps.sh"
source "$(dirname "${BASH_SOURCE[0]}")/events.sh"


WATCH_STATE="$FUMETAOS_HOME/data/watch-state"

mkdir -p "$WATCH_STATE"


###########################################################
# Estado
###########################################################

state_get()
{

FILE="$WATCH_STATE/$1"

if [ -f "$FILE" ]; then
    cat "$FILE"
fi

}


state_set()
{

echo "$2" > "$WATCH_STATE/$1"

}



###########################################################
# Servicios
###########################################################

check_services()
{

SERVICES="casaos docker tailscaled noip-duc ssh"


for SERVICE in $SERVICES
do

    if systemctl is-active --quiet "$SERVICE"
    then
        CURRENT="ok"
    else
        CURRENT="failed"
    fi


    OLD=$(state_get "service-$SERVICE")


    if [ "$CURRENT" != "$OLD" ]
    then

        if [ "$CURRENT" = "failed" ]
        then

            event_error \
            "Servicio detenido" \
            "$SERVICE no está activo"


        elif [ "$OLD" = "failed" ]
        then

            event_recovery \
            "Servicio recuperado" \
            "$SERVICE vuelve a estar activo"

        fi

    fi


    state_set "service-$SERVICE" "$CURRENT"


done

}
