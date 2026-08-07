#!/bin/bash

###########################################################
# FumetaOS
# Apps Core
###########################################################

###########################################################
# Cargar núcleo FumetaOS
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

###########################################################
# Lista aplicaciones instaladas
###########################################################

app_list()
{

for APP in "$APPS_DIR"/*
do

    [ -d "$APP" ] || continue
    [ -f "$APP/app.conf" ] || continue

    echo "$APP"

done

}

###########################################################
# Cargar configuración aplicación
###########################################################

app_load()
{

APP_PATH="$1"

if [ ! -f "$APP_PATH/app.conf" ]; then
    return 1
fi

source "$APP_PATH/app.conf"

}

###########################################################
# Comprueba si aplicación está ejecutándose
###########################################################

app_running()
{

docker ps --format '{{.Names}}' | grep -qx "$APP_ID"

}

###########################################################
# Devuelve versión aplicación
###########################################################

app_version()
{

echo "$APP_VERSION"

}
