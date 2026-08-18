#!/bin/bash

###########################################################

# FumetaOS

# Monitor de seguridad

###########################################################

ERROR=0


echo


###########################################################
# Firewall
###########################################################

if ! command -v ufw >/dev/null 2>&1
then

    echo "🔴 Firewall UFW no instalado"
    exit 20

fi


STATUS=$(sudo ufw status 2>/dev/null | head -1)


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

POLICY=$(sudo ufw status verbose 2>/dev/null | grep "Default:")


if [ -n "$POLICY" ]
then

    echo "🔒 $POLICY"

fi



exit "$ERROR"
