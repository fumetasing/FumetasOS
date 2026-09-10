#!/bin/bash

###########################################################
# FumetaOS
# CasaOS Integration Core
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"


casaos_metadata_dir()
{

echo "$APP_DATA/.fumetaos/casaos"

}


casaos_prepare_dir()
{

DIR="$1"


if [ -d "$DIR" ]; then

    return 0

fi


mkdir -p "$DIR" 2>/dev/null


if [ $? -ne 0 ]; then

    sudo mkdir -p "$DIR"
    sudo chown -R "$USER:$USER" "$(dirname "$(dirname "$DIR")")"
fi

}


casaos_generate()
{

APP_PATH="$1"

[ -f "$APP_PATH/app.conf" ] || return 1


source "$APP_PATH/app.conf"


DIR=$(casaos_metadata_dir)


casaos_prepare_dir "$DIR"


cat > "$DIR/app.yaml" <<EOF
name: $APP_NAME
description: $APP_DESCRIPTION
category: $APP_CATEGORY
icon: $APP_ICON
author: $APP_AUTHOR

port: $APP_PORT

webui: $APP_WEBUI

image: $APP_IMAGE:$APP_TAG

container: $APP_CONTAINER
EOF


echo
echo "✅ Metadata CasaOS generada"
echo
echo "$DIR/app.yaml"

}


casaos_show()
{

APP_PATH="$1"

[ -f "$APP_PATH/app.conf" ] || return 1


source "$APP_PATH/app.conf"


DIR=$(casaos_metadata_dir)


if [ -f "$DIR/app.yaml" ]; then

    cat "$DIR/app.yaml"

else

    echo "❌ Metadata CasaOS no encontrada"

fi

}
