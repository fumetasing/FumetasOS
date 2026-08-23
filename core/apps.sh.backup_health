#!/bin/bash

###########################################################
# FumetaOS
# Apps Core v2
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


unset APP_ID
unset APP_NAME
unset APP_DESCRIPTION
unset APP_CATEGORY
unset APP_ICON
unset APP_ICON_URL

unset APP_TYPE
unset APP_IMAGE
unset APP_TAG
unset APP_CONTAINER

unset APP_INDEX
unset APP_PORT
unset APP_PORT_MAP
unset APP_PORTS
unset APP_URL
unset APP_WEBUI

unset APP_COMPOSE
unset APP_DATA
unset APP_ENV
unset APP_VOLUMES

unset APP_VERSION
unset APP_AUTHOR


source "$APP_PATH/app.conf"

}


app_container()
{

if [ -n "$APP_CONTAINER" ]; then

    echo "$APP_CONTAINER"

else

    echo "$APP_ID"

fi

}


app_description()
{

echo "$APP_DESCRIPTION"

}


app_category()
{

echo "$APP_CATEGORY"

}


app_icon()
{

echo "$APP_ICON"

}


app_url()
{

echo "$APP_URL"

}


app_webui()
{

echo "$APP_WEBUI"

}


app_report_url()
{

if [ -n "$APP_URL" ]; then

    echo "$APP_URL"

elif [ -n "$APP_WEBUI" ]; then

    echo "${APP_WEBUI//\[IP\]/localhost}"

fi

}


app_author()
{

echo "$APP_AUTHOR"

}


app_running()
{

CONTAINER=$(app_container)

docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"

}


app_health()
{

CONTAINER=$(app_container)

docker inspect "$CONTAINER" --format '{{.State.Health.Status}}' 2>/dev/null

}


app_version()
{

echo "$APP_VERSION"

}


app_install()
{

APP_PATH="$1"

app_load "$APP_PATH" || return 1


if app_running; then

    echo
    echo "⚠️ $APP_NAME ya está ejecutándose"
    return 1

fi


echo
echo "📦 Instalando $APP_NAME"
echo


if [ -z "$APP_COMPOSE" ]; then

    echo "❌ No existe archivo compose para $APP_NAME"
    return 1

fi


if [ ! -f "$APP_COMPOSE" ]; then

    echo "❌ No existe compose: $APP_COMPOSE"
    return 1

fi


mkdir -p "$APP_DATA"


cd "$APP_DATA" || return 1


docker compose -f "$APP_COMPOSE" up -d


if [ $? -eq 0 ]; then

    echo
    echo "✅ $APP_NAME instalado"

else

    echo
    echo "❌ Error instalando $APP_NAME"
    return 1

fi

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


[ -n "$APP_DESCRIPTION" ] && echo "Descripción: $APP_DESCRIPTION"

[ -n "$APP_CATEGORY" ] && echo "Categoría: $APP_CATEGORY"


if app_running
then

    echo "Estado: 🟢 Ejecutando"

else

    echo "Estado: 🔴 Detenido"

fi


echo "Versión: $APP_VERSION"
echo "Imagen: $APP_IMAGE:$APP_TAG"
echo "Contenedor: $(app_container)"

[ -n "$APP_PORT" ] && echo "Puerto: $APP_PORT"

REPORT_URL=$(app_report_url)

[ -n "$REPORT_URL" ] && echo "URL: $REPORT_URL"


HEALTH=$(app_health)


if [ "$HEALTH" = "healthy" ]; then

    echo "Health: 🟢 healthy"

elif [ "$HEALTH" = "unhealthy" ]; then

    echo "Health: 🔴 unhealthy"

else

    echo "Health: 🟡 Sin healthcheck"

fi


echo

}


app_check()
{

APP_PATH="$1"

app_load "$APP_PATH" || return 1


echo
echo "🔎 Comprobación $APP_NAME"
echo


if [ -f "$APP_COMPOSE" ]; then

    echo "Compose: 🟢 Encontrado"

else

    echo "Compose: 🔴 No encontrado"

fi


echo "Imagen: $APP_IMAGE:$APP_TAG"
echo "Contenedor: $(app_container)"


HEALTH=$(app_health)


if [ "$HEALTH" = "healthy" ]; then

    echo "Health: 🟢 healthy"

elif [ "$HEALTH" = "unhealthy" ]; then

    echo "Health: 🔴 unhealthy"

else

    if app_running; then

        echo "Health: 🟡 Sin healthcheck"

    else

        echo "Health: 🔴 No disponible"

    fi

fi


if app_running
then

    echo "Estado: 🟢 Ejecutando"

else

    echo "Estado: 🔴 Detenida"

fi

echo

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
