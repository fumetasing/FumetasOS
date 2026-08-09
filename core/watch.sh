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

SERVICES="casaos docker tailscaled ssh"


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



###########################################################
# Temperatura
###########################################################

check_temperature()
{

TEMP=$(cpu_temp)


[ -z "$TEMP" ] && return


if [ "$TEMP" -ge "$CPU_CRITICAL" ]
then

CURRENT="critical"


elif [ "$TEMP" -ge "$CPU_WARNING" ]
then

CURRENT="warning"


else

CURRENT="ok"

fi


OLD=$(state_get temperature)


if [ "$CURRENT" != "$OLD" ]
then


case "$CURRENT" in


critical)

event_error \
"CPU crítica" \
"Temperatura: ${TEMP}°C"

;;


warning)

event_warning \
"CPU alta" \
"Temperatura: ${TEMP}°C"

;;


ok)

if [ "$OLD" = "warning" ] || [ "$OLD" = "critical" ]
then

event_recovery \
"Temperatura normalizada" \
"CPU: ${TEMP}°C"

fi

;;


esac


fi


state_set temperature "$CURRENT"

}



###########################################################
# Discos
###########################################################

check_disks()
{

USAGE=$(df "$DATA_MOUNT" | awk 'NR==2 {gsub("%","",$5);print $5}')


if [ "$USAGE" -ge "$DISK_CRITICAL" ]
then

CURRENT="critical"


elif [ "$USAGE" -ge "$DISK_WARNING" ]
then

CURRENT="warning"


else

CURRENT="ok"

fi


OLD=$(state_get disk)


if [ "$CURRENT" != "$OLD" ]
then


case "$CURRENT" in


critical)

event_error \
"Disco crítico" \
"HDD Datos: ${USAGE}%"

;;


warning)

event_warning \
"Disco lleno" \
"HDD Datos: ${USAGE}%"

;;


ok)

if [ "$OLD" = "warning" ] || [ "$OLD" = "critical" ]
then

event_recovery \
"Disco normalizado" \
"HDD Datos: ${USAGE}%"

fi

;;


esac


fi


state_set disk "$CURRENT"

}



###########################################################
# Aplicaciones
###########################################################

check_apps()
{


for APP_PATH in $(app_list)
do


APP_ID=$(basename "$APP_PATH")


app_load "$APP_PATH"


CONTAINER=$(app_container)


if docker inspect "$CONTAINER" >/dev/null 2>&1
then

HEALTH=$(docker inspect \
--format='{{.State.Health.Status}}' \
"$CONTAINER" 2>/dev/null)

else

HEALTH="stopped"

fi


OLD=$(state_get "app-$APP_ID")


if [ "$HEALTH" != "$OLD" ]
then


if [ "$HEALTH" = "unhealthy" ]
then

event_error \
"Aplicación con problemas" \
"$APP_NAME health: unhealthy"


elif [ "$OLD" = "unhealthy" ] && [ "$HEALTH" = "healthy" ]
then

event_recovery \
"Aplicación recuperada" \
"$APP_NAME vuelve a estar healthy"


fi


fi


state_set "app-$APP_ID" "$HEALTH"


done


}



###########################################################
# Ejecutar vigilancia
###########################################################

watch_run()
{

check_services

check_temperature

check_disks

check_apps

}
