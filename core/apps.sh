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

app_load "$APP_PATH" || return 1

echo
echo "🔄 Actualizando $APP_NAME"
echo

cd "$APP_DATA" || return 1

docker compose -f "$APP_COMPOSE" pull || return 1

docker compose -f "$APP_COMPOSE" up -d || return 1

echo
echo "✅ $APP_NAME actualizado"

}

###########################################################
# Reiniciar aplicación
###########################################################

app_restart()
{

APP_PATH="$1"

app_load "$APP_PATH" || return 1

echo
echo "🔄 Reiniciando $APP_NAME"
echo

cd "$APP_DATA" || return 1

docker compose -f "$APP_COMPOSE" restart || return 1

echo
echo "✅ $APP_NAME reiniciado"

}

###########################################################
# Logs aplicación
###########################################################

app_logs()
{

APP_PATH="$1"

app_load "$APP_PATH" || return 1

echo
echo "📜 Logs de $APP_NAME"
echo

cd "$APP_DATA" || return 1

docker compose -f "$APP_COMPOSE" logs --tail=100

}
