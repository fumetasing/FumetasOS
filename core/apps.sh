#!/bin/bash

###########################################################
# FumetaOS
# Apps Core
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"


app_list()
{

for APP in "$APPS_DIR"/*
do

    [ -d "$APP" ] || continue
    [ -f "$APP/app.conf" ] || continue

    echo "$APP"

done

}


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


app_load()
{

APP_PATH="$1"

[ -f "$APP_PATH/app.conf" ] || return 1

source "$APP_PATH/app.conf"

}


app_running()
{

docker ps --format '{{.Names}}' | grep -qx "$APP_ID"

}


app_version()
{

echo "$APP_VERSION"

}


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


app_status()
{

APP_PATH="$1"

app_load "$APP_PATH" || return 1

echo
echo "📦 $APP_NAME"
echo

if app_running
then
    echo "Estado: 🟢 Ejecutando"
else
    echo "Estado: 🔴 Detenido"
fi

echo "Versión: $APP_VERSION"
echo "Imagen: $APP_IMAGE:$APP_TAG"

}


app_remove()
{

APP_PATH="$1"

app_load "$APP_PATH" || return 1

echo
echo "🗑️ Eliminando $APP_NAME"
echo

cd "$APP_DATA" || return 1

docker compose -f "$APP_COMPOSE" down

if [ $? -eq 0 ]; then

    echo
    echo "✅ $APP_NAME eliminado"

else

    echo
    echo "❌ Error eliminando $APP_NAME"

    return 1

fi

}
