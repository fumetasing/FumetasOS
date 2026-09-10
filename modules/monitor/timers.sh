#!/bin/bash

###########################################################
# FumetaOS
# Monitor de temporizadores
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/../../core/services.sh"

ERROR=0

echo

for timer in $FUMETAOS_TIMERS; do
	if unit_is_active "$timer"; then
		echo "✅ $timer"
	else
		echo "🚨 $timer"
		ERROR=20
	fi
done

exit "$ERROR"
