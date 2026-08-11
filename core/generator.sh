#!/bin/bash

###########################################################
# FumetaOS
# Generator Core
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"


generate_compose()
{

APP_PATH="$1"

[ -f "$APP_PATH/app.conf" ] || return 1


source "$APP_PATH/app.conf"


mkdir -p "$APP_DATA"


FILE="$APP_DATA/compose.yaml"


cat > "$FILE" <<EOF_COMPOSE
services:

  $APP_ID:

    image: $APP_IMAGE:$APP_TAG

    container_name: $APP_CONTAINER

EOF_COMPOSE


###########################################################
# Puertos
###########################################################

if [ -n "$APP_PORT" ] || [ -n "$APP_PORTS" ]; then

echo "    ports:" >> "$FILE"


if [ -n "$APP_PORT" ]; then

echo "      - \"$APP_PORT:$APP_PORT\"" >> "$FILE"

fi


if [ -n "$APP_PORTS" ]; then

while IFS= read -r PORT_LINE
do

    [ -z "$PORT_LINE" ] && continue

    echo "      - \"$PORT_LINE\"" >> "$FILE"

done <<< "$APP_PORTS"

fi


echo >> "$FILE"

fi


###########################################################
# Variables de entorno
###########################################################

if [ -n "$APP_ENV" ]; then

echo "    environment:" >> "$FILE"

while IFS= read -r ENV_LINE
do

    [ -z "$ENV_LINE" ] && continue

    echo "      - \"$ENV_LINE\"" >> "$FILE"

done <<< "$APP_ENV"

echo >> "$FILE"

fi


###########################################################
# Volúmenes
###########################################################

if [ -n "$APP_VOLUMES" ]; then

echo "    volumes:" >> "$FILE"

while IFS= read -r VOLUME_LINE
do

    [ -z "$VOLUME_LINE" ] && continue

    echo "      - $VOLUME_LINE" >> "$FILE"

done <<< "$APP_VOLUMES"

echo >> "$FILE"

fi


###########################################################
# Reinicio
###########################################################

cat >> "$FILE" <<EOF_RESTART
    restart: unless-stopped

EOF_RESTART


echo

echo "✅ Compose generado"

echo "$FILE"

}


generate_app_structure()
{

APP_PATH="$1"

[ -f "$APP_PATH/app.conf" ] || return 1


source "$APP_PATH/app.conf"


mkdir -p "$APP_DATA"

mkdir -p "$APP_DATA/config"

mkdir -p "$APP_DATA/cache"


###########################################################
# Scripts de aplicación
###########################################################

if [ -d "$APP_PATH/scripts" ]; then

    mkdir -p "$APP_DATA/config/scripts"

    cp -r "$APP_PATH/scripts/." \
        "$APP_DATA/config/scripts/"

    find "$APP_DATA/config/scripts" \
        -type f \
        -exec chmod 755 {} \;

fi


echo

echo "✅ Estructura creada"

}
