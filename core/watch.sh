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

for SERVICE in $SYSTEM_SERVICES
do

    if systemctl is-active --quiet "$SERVICE"
    then
        CURRENT="ok"
    else
        CURRENT="failed"
    fi


    OLD=$(state_get "service-$SERVICE")


    #######################################################
    # Servicio caído
    #######################################################

    if [ "$CURRENT" = "failed" ]
    then

        if [ "$OLD" = "warning" ]
        then

            event_error \
            "Servicio detenido" \
            "$SERVICE no está activo"

            state_set "service-$SERVICE" "failed"


        elif [ "$OLD" = "ok" ] || [ -z "$OLD" ]
        then

            state_set "service-$SERVICE" "warning"

        fi


    #######################################################
    # Servicio recuperado
    #######################################################

    elif [ "$CURRENT" = "ok" ]
    then

        if [ "$OLD" = "warning" ] || [ "$OLD" = "failed" ]
        then

            event_recovery \
            "Servicio recuperado" \
            "$SERVICE vuelve a estar activo"

        fi


        state_set "service-$SERVICE" "ok"

    fi


done

}



###########################################################
# Ejecutar Watch
###########################################################

watch_run()
{

check_services

}
