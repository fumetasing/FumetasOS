#!/bin/bash

###########################################################

# FumetaOS

# Monitor Time Capsule

###########################################################

ERROR=0

if systemctl is-active --quiet fumetaos-timecapsule.service &&
   systemctl is-active --quiet fumetaos-timecapsule-casaos.service &&
   findmnt -rn -M /DATA/TimeCapsule >/dev/null 2>&1
then

    echo "🟢 Time Capsule AFP"
    echo "   Montaje: /DATA/TimeCapsule"

else

    echo "🔴 Time Capsule AFP no disponible"
    ERROR=20

fi

exit "$ERROR"
