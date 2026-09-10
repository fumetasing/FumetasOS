#!/bin/bash

###########################################################

# FumetaOS

# Monitor Time Capsule

###########################################################

AFP_MOUNT="/mnt/timecapsule"
CASAOS_MOUNT="/DATA/TimeCapsule"
AFP_CLIENT="/usr/local/bin/mount_afpfs"

ERROR=0

if [ ! -x "$AFP_CLIENT" ]
then

    echo "🔴 Cliente AFP no disponible"
    echo "   Esperado: $AFP_CLIENT"
    ERROR=20

elif ! systemctl is-active --quiet fumetaos-timecapsule.service
then

    echo "🔴 Servicio AFP de Time Capsule no activo"
    ERROR=20

elif ! findmnt -rn -M "$AFP_MOUNT" >/dev/null 2>&1
then

    echo "🔴 Time Capsule AFP no montada"
    echo "   Punto interno: $AFP_MOUNT"
    ERROR=20

elif ! systemctl is-active --quiet fumetaos-timecapsule-casaos.service
then

    echo "🔴 Servicio de Time Capsule para CasaOS no activo"
    ERROR=20

elif ! findmnt -rn -M "$CASAOS_MOUNT" >/dev/null 2>&1
then

    echo "🔴 Time Capsule no disponible en CasaOS"
    echo "   Punto esperado: $CASAOS_MOUNT"
    ERROR=20

elif ! ls "$CASAOS_MOUNT" >/dev/null 2>&1
then

    echo "🔴 Time Capsule montada pero sin acceso desde CasaOS"
    echo "   Punto: $CASAOS_MOUNT"
    ERROR=20

else

    echo "🟢 Time Capsule AFP"
    echo "   AFP: $AFP_MOUNT"
    echo "   CasaOS: $CASAOS_MOUNT"
    echo "   Acceso: disponible"

fi

exit "$ERROR"
