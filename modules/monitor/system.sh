#!/bin/bash

###########################################################
# FumetaOS
# Monitor del sistema
###########################################################

echo

UPTIME=$(uptime -p | sed 's/up //')

IP=$(hostname -I | awk '{print $1}')

KERNEL=$(uname -r)


echo "⏱️ Uptime: $UPTIME"
echo "🌐 IP: $IP"
echo "🐧 Kernel: $KERNEL"

exit 0
