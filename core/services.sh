#!/bin/bash

###########################################################
# FumetaOS
# Services Core
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

###########################################################
# Estado de unidades systemd
###########################################################

unit_is_active() {
	systemctl is-active --quiet "$1"
}

###########################################################
# Estado servicio
###########################################################

service_state() {
	if unit_is_active "$1"; then
		echo "active"
	else
		echo "inactive"
	fi
}

###########################################################
# Estado timer
###########################################################

timer_state() {
	service_state "$1"
}

###########################################################
# Mostrar servicios
###########################################################

services_show() {
	local timer
	local service
	local state

	echo
	echo "⚙️ Servicios FumetaOS"
	echo

	echo "⏱️ Timers"
	echo "─────────"

	for timer in $FUMETAOS_TIMERS; do
		state="$(timer_state "$timer")"

		if [ "$state" = "active" ]; then
			echo "🟢 $timer"
		else
			echo "🔴 $timer"
		fi
	done

	echo

	echo "🛠️ Sistema"
	echo "──────────"

	for service in $SYSTEM_SERVICES; do
		state="$(service_state "$service")"

		if [ "$state" = "active" ]; then
			echo "🟢 $service"
		else
			echo "🔴 $service"
		fi
	done

	echo
}
