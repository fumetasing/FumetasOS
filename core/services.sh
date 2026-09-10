#!/bin/bash

###########################################################

# FumetaOS
# Services Core

###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"



###########################################################
# Estado servicio
###########################################################

service_state()
{

SERVICE="$1"

if systemctl is-active --quiet "$SERVICE"
then

    echo "active"

else

    echo "inactive"

fi

}



###########################################################
# Estado timer
###########################################################

timer_state()
{

TIMER="$1"

if systemctl is-active --quiet "$TIMER"
then

    echo "active"

else

    echo "inactive"

fi

}



###########################################################
# Mostrar servicios
###########################################################

services_show()
{

echo
echo "⚙️ Servicios FumetaOS"
echo


echo "⏱️ Timers"
echo "─────────"


for TIMER in $FUMETAOS_TIMERS
do

    STATE=$(timer_state "$TIMER")

    if [ "$STATE" = "active" ]
    then

        echo "🟢 $TIMER"

    else

        echo "🔴 $TIMER"

    fi

done


echo

echo "🛠️ Sistema"
echo "──────────"


for SERVICE in $SYSTEM_SERVICES
do

    STATE=$(service_state "$SERVICE")

    if [ "$STATE" = "active" ]
    then

        echo "🟢 $SERVICE"

    else

        echo "🔴 $SERVICE"

    fi

done


echo

}
