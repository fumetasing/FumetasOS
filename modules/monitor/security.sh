#!/bin/bash

###########################################################
# FumetaOS
# Monitor de seguridad
###########################################################

ERROR=0
UFW_BIN="/usr/sbin/ufw"

echo

###########################################################
# Firewall
###########################################################

if [ ! -x "$UFW_BIN" ]
then
    echo "🔴 Firewall UFW no instalado"
    exit 20
fi

if ! sudo -n "$UFW_BIN" status >/dev/null 2>&1
then
    echo "🔴 No se puede consultar el Firewall UFW"
    exit 20
fi

STATUS=$(sudo -n "$UFW_BIN" status 2>/dev/null | sed -n '1p')

if echo "$STATUS" | grep -q "active"
then
    echo "🟢 Firewall UFW activo"
else
    echo "🔴 Firewall UFW inactivo"
    ERROR=20
fi

###########################################################
# Políticas
###########################################################

POLICY=$(sudo -n "$UFW_BIN" status verbose 2>/dev/null |
    sed -n '/^Default:/ {p; q;}')

if [ -n "$POLICY" ]
then
    echo "🔒 $POLICY"
fi

exit "$ERROR"
