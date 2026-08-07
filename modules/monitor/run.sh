#!/bin/bash

###########################################################
# FumetaOS
# Motor de monitorización
###########################################################

ERROR=0

echo "🛠️ Servicios"
/opt/fumetaos/modules/monitor/services.sh
RET=$?

if [ "$RET" -gt "$ERROR" ]; then
    ERROR=$RET
fi

echo
echo "💚 SMART"
/opt/fumetaos/modules/monitor/smart.sh
RET=$?

if [ "$RET" -gt "$ERROR" ]; then
    ERROR=$RET
fi

echo
echo "🌡️ Temperatura"
/opt/fumetaos/modules/monitor/temperature.sh
RET=$?

if [ "$RET" -gt "$ERROR" ]; then
    ERROR=$RET
fi

echo
echo "💾 Discos"
/opt/fumetaos/modules/monitor/disks.sh
RET=$?

if [ "$RET" -gt "$ERROR" ]; then
    ERROR=$RET
fi

echo
echo "🧠 Memoria"
/opt/fumetaos/modules/monitor/memory.sh
RET=$?

if [ "$RET" -gt "$ERROR" ]; then
    ERROR=$RET
fi

echo
echo "📦 Actualizaciones"
/opt/fumetaos/modules/monitor/updates.sh
RET=$?

if [ "$RET" -gt "$ERROR" ]; then
    ERROR=$RET
fi

exit $ERROR
