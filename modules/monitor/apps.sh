#!/bin/bash

###########################################################
# FumetaOS
# Monitor de aplicaciones
###########################################################

source /opt/fumetaos/core/common.sh
source /opt/fumetaos/core/apps.sh


ERROR=0

TOTAL=0
ACTIVE=0
FAILED=0


echo


for APP in $(app_list)
do

    TOTAL=$((TOTAL+1))

done


echo "Total: $TOTAL"


for APP in $(app_list)
do

    app_load "$APP" || continue


    if app_running
    then
        ACTIVE=$((ACTIVE+1))
    else
        FAILED=$((FAILED+1))
    fi

done


echo "Activas: $ACTIVE"
echo "Problemas: $FAILED"

echo


for APP in $(app_list)
do

    app_load "$APP" || continue


    if app_running
    then

        echo "🟢 $APP_NAME"

        if [ -n "$APP_DESCRIPTION" ]; then
            echo "   $APP_DESCRIPTION"
        fi

        echo "   Estado: 🟢 Ejecutando"
        echo "   Versión: $APP_VERSION"

        if [ -n "$APP_URL" ]; then
            echo "   URL: $APP_URL"
        fi

        if [ -n "$APP_PORT" ]; then
            echo "   Puerto: $APP_PORT"
        fi


        HEALTH=$(app_health)


        if [ "$HEALTH" = "healthy" ]; then

            echo "   Health: 🟢 healthy"

        elif [ "$HEALTH" = "unhealthy" ]; then

            echo "   Health: 🔴 unhealthy"
            ERROR=20

        else

            echo "   Health: 🟡 Sin healthcheck"

        fi


    else

        echo "🔴 $APP_NAME"

        if [ -n "$APP_DESCRIPTION" ]; then
            echo "   $APP_DESCRIPTION"
        fi

        echo "   Estado: 🔴 Detenido"

        ERROR=20

    fi


    echo

done


if [ "$FAILED" -gt 0 ]; then
    ERROR=20
fi


exit "$ERROR"
