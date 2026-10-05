#!/bin/bash

###########################################################
# FumetaOS
# Monitor Time Capsule
###########################################################

TIMECAPSULE_MOUNT="/mnt/timecapsule"
CASAOS_MOUNT="/DATA/TimeCapsule"
SMB_CLIENT="/usr/sbin/mount.cifs"

WARNING_USAGE=90
HIGH_USAGE=93
CRITICAL_USAGE=95

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

	echo "🔴 Servicio de Time Capsule para casaOS no activo"
	ERROR=20

elif ! findmnt -rn -M "$CASAOS_MOUNT" >/dev/null 2>&1; then

	echo "🔴 Time Capsule no disponible en casaOS"
	echo "   Punto esperado: $CASAOS_MOUNT"
	ERROR=20

elif ! ls "$CASAOS_MOUNT" >/dev/null 2>&1; then

	echo "🔴 Time Capsule montada pero sin acceso desde casaOS"
	echo "   Punto: $CASAOS_MOUNT"
	ERROR=20

else
	ESPACIO="$(
		df -hP "$TIMECAPSULE_MOUNT" |
			awk 'NR == 2 { gsub("%", "", $5); print $4 "|" $5 }'
	)"

	LIBRE="${ESPACIO%|*}"
	USO="${ESPACIO#*|}"

	if [[ ! "$USO" =~ ^[0-9]+$ ]]; then
		echo "🔴 No se pudo determinar el uso de Time Capsule"
		ERROR=20
	elif [ "$USO" -ge "$CRITICAL_USAGE" ]; then
		echo "🔴 Time Capsule SMB — espacio crítico"
		ERROR=20
	elif [ "$USO" -ge "$HIGH_USAGE" ]; then
		echo "🟠 Time Capsule SMB — espacio muy reducido"
		ERROR=10
	elif [ "$USO" -ge "$WARNING_USAGE" ]; then
		echo "🟡 Time Capsule SMB — vigilar espacio"
		ERROR=10
	else
		echo "🟢 Time Capsule SMB"
	fi

	echo "   SMB: $TIMECAPSULE_MOUNT"
	echo "   casaOS: $CASAOS_MOUNT"
	echo "   Protocolo: SMB 3.1.1"
	echo "   Acceso: disponible"
	echo "   Libre: $LIBRE"
	echo "   Uso:   ${USO}%"

	case "$USO" in
	'' | *[!0-9]*) ;;
	*)
		if [ "$USO" -ge "$CRITICAL_USAGE" ]; then
			echo "   Umbral: crítico desde ${CRITICAL_USAGE}%"
		elif [ "$USO" -ge "$HIGH_USAGE" ]; then
			echo "   Umbral: muy reducido desde ${HIGH_USAGE}%"
		elif [ "$USO" -ge "$WARNING_USAGE" ]; then
			echo "   Umbral: aviso desde ${WARNING_USAGE}%"
		fi
		;;
	esac
fi

exit "$ERROR"
