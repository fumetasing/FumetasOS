#!/bin/bash

###########################################################
# FumetaOS
# Monitor Time Capsule
###########################################################

TIMECAPSULE_MOUNT="/mnt/timecapsule"
CASAOS_MOUNT="/DATA/TimeCapsule"
SMB_CLIENT="/usr/sbin/mount.cifs"

ERROR=0

if [ ! -x "$SMB_CLIENT" ]; then

	echo "🔴 Cliente SMB no disponible"
	echo "   Esperado: $SMB_CLIENT"
	ERROR=20

elif ! systemctl is-active --quiet fumetaos-timecapsule.service; then

	echo "🔴 Servicio SMB de Time Capsule no activo"
	ERROR=20

elif [ "$(findmnt -rn -M "$TIMECAPSULE_MOUNT" -o FSTYPE 2>/dev/null)" != "cifs" ]; then

	echo "🔴 Time Capsule SMB no montada"
	echo "   Punto interno: $TIMECAPSULE_MOUNT"
	ERROR=20

elif ! systemctl is-active --quiet fumetaos-timecapsule-casaos.service; then

	echo "🔴 Servicio de Time Capsule para CasaOS no activo"
	ERROR=20

elif ! findmnt -rn -M "$CASAOS_MOUNT" >/dev/null 2>&1; then

	echo "🔴 Time Capsule no disponible en CasaOS"
	echo "   Punto esperado: $CASAOS_MOUNT"
	ERROR=20

elif ! ls "$CASAOS_MOUNT" >/dev/null 2>&1; then

	echo "🔴 Time Capsule montada pero sin acceso desde CasaOS"
	echo "   Punto: $CASAOS_MOUNT"
	ERROR=20

else

	echo "🟢 Time Capsule SMB"
	echo "   SMB: $TIMECAPSULE_MOUNT"
	echo "   CasaOS: $CASAOS_MOUNT"
	echo "   Protocolo: SMB 3.1.1"
	echo "   Acceso: disponible"

	ESPACIO="$(df -hP "$TIMECAPSULE_MOUNT" | awk 'NR == 2 { print $4 "|" $5 }')"
	echo "   Libre: ${ESPACIO%|*}"
	echo "   Uso:   ${ESPACIO#*|}"

fi

exit "$ERROR"
