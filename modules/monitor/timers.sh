#!/bin/bash

###########################################################

# FumetaOS

# Monitor de timers

###########################################################

source "$(dirname "$0")/../../core/common.sh"


ERROR=0


echo


for TIMER in $FUMETAOS_TIMERS
do

    if systemctl is-active --quiet "$TIMER"
    then

        echo "✅ $TIMER"

    else

        echo "🚨 $TIMER"

        ERROR=20

    fi

done


exit "$ERROR"
