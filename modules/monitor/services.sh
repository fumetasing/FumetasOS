#!/bin/bash

###########################################################
# FumetaOS
# Monitor de servicios
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/../../core/services.sh"

WATCH=0

if [ "${1:-}" = "--watch" ]; then
	WATCH=1
fi

ERROR=0

for service in $SYSTEM_SERVICES; do
	if unit_is_active "$service"; then
		if [ "$WATCH" -eq 0 ]; then
			echo "✅ $service"
		fi
	else
		if [ "$WATCH" -eq 0 ]; then
			echo "🚨 $service"
		else
			echo "Servicio detenido: $service"
		fi

		ERROR=20
	fi
done

exit "$ERROR"
