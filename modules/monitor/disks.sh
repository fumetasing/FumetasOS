#!/bin/bash

###########################################################
# FumetaOS
# Monitor de discos
###########################################################

source /opt/fumetaos/core/common.sh

WATCH=0

if [ "$1" = "--watch" ]; then
    WATCH=1
fi

ERROR=0

check_disk() {

    DEVICE="$1"
    NAME="$2"
    MOUNT="$3"

    USE=$(df "$MOUNT" | awk 'NR==2 {gsub("%","",$5); print $5}')
    FREE=$(df -h "$MOUNT" | awk 'NR==2 {print $4}')

    if [ "$USE" -lt "$DISK_WARNING" ]; then

        if [ "$WATCH" -eq 0 ]; then
            echo "🟢 $NAME"
            echo "   Libre: $FREE"
            echo "   Uso:   ${USE}%"
            echo
        fi

    elif [ "$USE" -lt "$DISK_CRITICAL" ]; then

        if [ "$WATCH" -eq 0 ]; then
            echo "🟡 $NAME"
            echo "   Libre: $FREE"
            echo "   Uso:   ${USE}%"
            echo
        else
            echo "$NAME al ${USE}%"
        fi

        ERROR=10

    else

        if [ "$WATCH" -eq 0 ]; then
            echo "🔴 $NAME"
            echo "   Libre: $FREE"
            echo "   Uso:   ${USE}%"
            echo
        else
            echo "$NAME al ${USE}%"
        fi

        ERROR=20

    fi

}

check_disk "$SSD_DEVICE" "$SSD_NAME" "/"
check_disk "$HDD_DEVICE" "$HDD_NAME" "/mnt/datos"

exit $ERROR
