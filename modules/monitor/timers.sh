#!/bin/bash

###########################################################
# FumetaOS
# Monitor de timers
###########################################################

ERROR=0


TIMERS=(
    fumetaos-watch.timer
    fumetaos-report.timer
    fumetaos-history.timer
    fumetaos-history-clean.timer
    fumetaos-backup.timer
)


echo


for TIMER in "${TIMERS[@]}"
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
