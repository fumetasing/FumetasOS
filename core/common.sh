#!/bin/bash

###########################################################
# FumetaOS
# Common Library
###########################################################

###########################################################
# Evitar cargar varias veces
###########################################################

if [ -n "${FUMETAOS_COMMON_LOADED:-}" ]; then
	return
fi

FUMETAOS_COMMON_LOADED=1

###########################################################
# Detectar directorio base de FumetaOS
###########################################################

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FUMETAOS_HOME="$(dirname "$COMMON_DIR")"

###########################################################
# Directorios
###########################################################

# Variables públicas de la biblioteca, usadas por los scripts
# que cargan este archivo.
# shellcheck disable=SC2034
BIN_DIR="$FUMETAOS_HOME/bin"

# shellcheck disable=SC2034
CORE_DIR="$FUMETAOS_HOME/core"

# shellcheck disable=SC2034
MODULES_DIR="$FUMETAOS_HOME/modules"

# shellcheck disable=SC2034
CONFIG_DIR="$FUMETAOS_HOME/config"

# shellcheck disable=SC2034
DATA_DIR="$FUMETAOS_HOME/data"

# shellcheck disable=SC2034
DOCS_DIR="$FUMETAOS_HOME/docs"

# shellcheck disable=SC2034
INSTALL_DIR="$FUMETAOS_HOME/install"

# shellcheck disable=SC2034
LIBEXEC_DIR="$FUMETAOS_HOME/libexec"

# shellcheck disable=SC2034
SERVICES_DIR="$FUMETAOS_HOME/services"

# shellcheck disable=SC2034
APPS_DIR="$FUMETAOS_HOME/apps"

###########################################################
# Archivos
###########################################################

# shellcheck disable=SC2034
VERSION_FILE="$FUMETAOS_HOME/VERSION"

# shellcheck disable=SC2034
CONFIG_FILE="$CONFIG_DIR/fumetaos.conf"

# shellcheck disable=SC2034
SERVICES_CONFIG="$CORE_DIR/services.conf"

###########################################################
# Cargar configuración
###########################################################

if [ -f "$CONFIG_FILE" ]; then
	# Archivo local cargado dinámicamente.
	# shellcheck disable=SC1090
	source "$CONFIG_FILE"
fi

###########################################################
# Cargar servicios FumetaOS
###########################################################

if [ -f "$SERVICES_CONFIG" ]; then
	# Archivo local cargado dinámicamente.
	# shellcheck disable=SC1090
	source "$SERVICES_CONFIG"
fi

###########################################################
# Utilidades
###########################################################

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

disk_name() {
	local device="$1"

	if [ "$device" = "$SSD_DEVICE" ]; then
		echo "$SSD_NAME"
	elif [ "$device" = "$HDD_DEVICE" ]; then
		echo "$HDD_NAME"
	else
		echo "$device"
	fi
}

smartctl_cmd() {
	if [ "$(id -u)" -eq 0 ]; then
		smartctl "$@"
	else
		sudo smartctl "$@"
	fi
}
