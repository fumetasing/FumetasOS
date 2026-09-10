#!/bin/bash

###########################################################
# FumetaOS
# Monitor de actualizaciones
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/../../core/system.sh"

WATCH=0

if [ "${1:-}" = "--watch" ]; then
	WATCH=1
fi

mostrar_estado() {
	local icon="$1"
	local message="$2"

	if [ "$WATCH" -eq 0 ]; then
		echo "$icon $message"
	else
		echo "$message"
	fi
}

if ! updates="$(updates_available)"; then
	mostrar_estado "❓" "No se pudo comprobar las actualizaciones"
	exit 20
fi

if [[ ! "$updates" =~ ^[0-9]+$ ]]; then
	mostrar_estado "❓" "Resultado de actualizaciones no válido"
	exit 20
fi

case "$updates" in
0)
	mostrar_estado "🟢" "Sistema al día"
	exit 0
	;;
[1-9] | [1-4][0-9])
	mostrar_estado "🟡" "$updates actualizaciones aplicables"
	exit 10
	;;
*)
	mostrar_estado "🔴" "$updates actualizaciones aplicables"
	exit 20
	;;
esac
