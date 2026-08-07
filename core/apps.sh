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
# Buscar aplicación por ID
###########################################################

app_find()
{

SEARCH_ID="$1"

for APP in $(app_list)
do

    source "$APP/app.conf"

    if [ "$APP_ID" = "$SEARCH_ID" ]; then
        echo "$APP"
        return 0
    fi

done

return 1

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

###########################################################
# Actualizar aplicación
###########################################################

app_update()
{

APP_PATH="$1"

if [ -z "$APP_PATH" ]; then
    return 1
fi


app_load "$APP_PATH" || return 1


if [ -z "$APP_COMPOSE" ]; then

    echo "❌ No existe archivo compose para $APP_NAME"
    return 1

fi


echo
echo "🔄 Actualizando $APP_NAME"
echo


cd "$APP_DATA" || return 1


docker compose -f "$APP_COMPOSE" pull

if [ $? -ne 0 ]; then

    echo
    echo "❌ Error descargando imagen"
    return 1

fi


docker compose -f "$APP_COMPOSE" up -d


if [ $? -eq 0 ]; then

    echo
    echo "✅ $APP_NAME actualizado"

else

    echo
    echo "❌ Error reiniciando $APP_NAME"
    return 1

fi

}
