#!/bin/bash

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

actualizaciones_listadas() {
	apt list --upgradable 2>/dev/null |
		awk '
			$0 !~ /^Listing/ && $0 ~ /\// {
				total++
			}

			END {
				print total + 0
			}
		'
}

if ! aplicables="$(updates_available)"; then
	mostrar_estado "❓" "No se pudo comprobar las actualizaciones"
	exit 20
fi

if ! listadas="$(actualizaciones_listadas)"; then
	mostrar_estado "❓" "No se pudo leer la lista de actualizaciones"
	exit 20
fi

if [[ ! "$aplicables" =~ ^[0-9]+$ ]] ||
	[[ ! "$listadas" =~ ^[0-9]+$ ]]; then
	mostrar_estado "❓" "Resultado de actualizaciones no válido"
	exit 20
fi

if [ "$listadas" -lt "$aplicables" ]; then
	listadas="$aplicables"
fi

graduales=$((listadas - aplicables))

case "$listadas" in
0)
	mostrar_estado "🟢" "Sistema al día"
	exit 0
	;;
[1-9] | [1-4][0-9])
	if [ "$graduales" -gt 0 ]; then
		mostrar_estado "🟡" \
			"$listadas actualizaciones disponibles ($graduales en despliegue gradual)"
	else
		mostrar_estado "🟡" "$listadas actualizaciones aplicables"
	fi
	exit 10
	;;
*)
	if [ "$graduales" -gt 0 ]; then
		mostrar_estado "🔴" \
			"$listadas actualizaciones disponibles ($graduales en despliegue gradual)"
	else
		mostrar_estado "🔴" "$listadas actualizaciones aplicables"
	fi
	exit 20
	;;
esac
