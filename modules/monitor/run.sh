#!/bin/bash

###########################################################
# FumetaOS
# Motor de monitorización
###########################################################

ERROR=0

run_monitor() {
	local title="$1"
	local script="$2"
	local status

	echo "$title"

	"$script"
	status=$?

	if [ "$status" -gt "$ERROR" ]; then
		ERROR="$status"
	fi

	echo
}

run_monitor \
	"🛠️ Servicios" \
	/opt/fumetaos/modules/monitor/services.sh

run_monitor \
	"⏱️ Timers FumetaOS" \
	/opt/fumetaos/modules/monitor/timers.sh

run_monitor \
	"💚 SMART" \
	/opt/fumetaos/modules/monitor/smart.sh

run_monitor \
	"💾 Discos" \
	/opt/fumetaos/modules/monitor/disks.sh

run_monitor \
	"🌡️ Temperatura" \
	/opt/fumetaos/modules/monitor/temperature.sh

run_monitor \
	"🧠 Memoria" \
	/opt/fumetaos/modules/monitor/memory.sh

run_monitor \
	"📦 Actualizaciones" \
	/opt/fumetaos/modules/monitor/updates.sh

exit "$ERROR"
