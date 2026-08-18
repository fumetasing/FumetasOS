#!/bin/bash

###########################################################

# FumetaOS
# Common Library

###########################################################


###########################################################
# Evitar cargar varias veces
###########################################################

[ -n "$FUMETAOS_COMMON_LOADED" ] && return

FUMETAOS_COMMON_LOADED=1



###########################################################
# Detectar directorio base de FumetaOS
###########################################################

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FUMETAOS_HOME="$(dirname "$COMMON_DIR")"



###########################################################
# Directorios
###########################################################

BIN_DIR="$FUMETAOS_HOME/bin"
CORE_DIR="$FUMETAOS_HOME/core"
MODULES_DIR="$FUMETAOS_HOME/modules"
CONFIG_DIR="$FUMETAOS_HOME/config"
DATA_DIR="$FUMETAOS_HOME/data"
DOCS_DIR="$FUMETAOS_HOME/docs"
INSTALL_DIR="$FUMETAOS_HOME/install"
LIBEXEC_DIR="$FUMETAOS_HOME/libexec"
SERVICES_DIR="$FUMETAOS_HOME/services"
APPS_DIR="$FUMETAOS_HOME/apps"



###########################################################
# Archivos
###########################################################

VERSION_FILE="$FUMETAOS_HOME/VERSION"
CONFIG_FILE="$CONFIG_DIR/fumetaos.conf"
SERVICES_CONFIG="$CORE_DIR/services.conf"



###########################################################
# Cargar configuración
###########################################################

if [ -f "$CONFIG_FILE" ]; then

    source "$CONFIG_FILE"

fi



###########################################################
# Cargar servicios FumetaOS
###########################################################

if [ -f "$SERVICES_CONFIG" ]; then

    source "$SERVICES_CONFIG"

fi



###########################################################
# Utilidades
###########################################################

command_exists()
{

command -v "$1" >/dev/null 2>&1

}



disk_name()
{

DEVICE="$1"


if [ "$DEVICE" = "$SSD_DEVICE" ]; then

    echo "$SSD_NAME"


elif [ "$DEVICE" = "$HDD_DEVICE" ]; then

    echo "$HDD_NAME"


else

    echo "$DEVICE"

fi

}



smartctl_cmd()
{

if [ "$(id -u)" -eq 0 ]; then

    smartctl "$@"

else

    sudo smartctl "$@"

fi

}
