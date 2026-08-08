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


cat > "$FILE" <<EOF
services:

  $APP_ID:

    image: $APP_IMAGE:$APP_TAG

    container_name: $APP_CONTAINER

    ports:
      - "$APP_PORT:$APP_PORT"

    restart: unless-stopped

EOF


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


echo

echo "✅ Estructura creada"

}
