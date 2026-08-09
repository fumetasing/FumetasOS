#!/bin/bash

###########################################################
# FumetaOS
# Events
###########################################################


source "$(dirname "${BASH_SOURCE[0]}")/common.sh"


event_send()
{

TYPE="$1"
TITLE="$2"
MESSAGE="$3"


case "$TYPE" in

info)

ICON="🟢"

;;

warning)

ICON="🟡"

;;

error)

ICON="🔴"

;;

recovery)

ICON="🟢"

;;

*)

ICON="ℹ️"

;;

esac


TEXT="
${ICON} FumetaOS ${TYPE^^}

${TITLE}

${MESSAGE}

Hora:
$(date '+%d/%m/%Y %H:%M')
"


echo "$TEXT" | "$BIN_DIR/telegram-notify"

}


event_warning()
{

event_send \
warning \
"$1" \
"$2"

}


event_error()
{

event_send \
error \
"$1" \
"$2"

}


event_recovery()
{

event_send \
recovery \
"$1" \
"$2"

}


event_info()
{

event_send \
info \
"$1" \
"$2"

}
