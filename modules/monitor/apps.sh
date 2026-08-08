#!/bin/bash

###########################################################
# FumetaOS
# Monitor de aplicaciones
###########################################################

source /opt/fumetaos/core/common.sh
source /opt/fumetaos/core/apps.sh


ERROR=0


echo


for APP in $(app_list)
do

    app_load "$APP" || continue


    if app_running
    then

        echo "🟢 $APP_NAME"
        echo "   Estado: 🟢 Ejecutando"
        echo "   Versión: $APP_VERSION"


        HEALTH=$(app_health)


        if [ "$HEALTH" = "healthy" ]; then

            echo "   Health: 🟢 healthy"

        elif [ "$HEALTH" = "unhealthy" ]; then

            echo "   Health: 🔴 unhealthy"
            ERROR=20

        fi


    else

        echo "🔴 $APP_NAME"
        echo "   Estado: 🔴 Detenido"

        ERROR=20

    fi


    echo

done


exit "$ERROR"
