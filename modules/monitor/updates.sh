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

if ! UPDATES="$(updates_available)"; then
	[ "$WATCH" -eq 0 ] && echo "❓ No se pudo comprobar las actualizaciones"
	exit 20
fi

if [ "$UPDATES" -eq 0 ]; then
	[ "$WATCH" -eq 0 ] && echo "🟢 Sistema al día"
	exit 0
elif [ "$UPDATES" -lt 50 ]; then
	if [ "$WATCH" -eq 0 ]; then
		echo "🟡 $UPDATES actualizaciones aplicables"
	else
		echo "$UPDATES actualizaciones aplicables"
	fi

	exit 10
else
	if [ "$WATCH" -eq 0 ]; then
		echo "🔴 $UPDATES actualizaciones aplicables"
	else
		echo "$UPDATES actualizaciones aplicables"
	fi

	exit 20
fi
