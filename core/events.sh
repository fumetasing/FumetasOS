#!/bin/bash

###########################################################
# FumetaOS
# Events
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"


EVENTS_FILE="$DATA_DIR/events.log"


mkdir -p "$DATA_DIR"



###########################################################
# Registrar evento
###########################################################

event_log()
{

TYPE="$1"
TITLE="$2"
MESSAGE="$3"


DATE=$(date +"%Y-%m-%d %H:%M:%S")


echo "$DATE | $TYPE | $TITLE | $MESSAGE" >> "$EVENTS_FILE"

}



###########################################################
# Enviar evento
###########################################################

event_send()
{

TYPE="$1"
TITLE="$2"
MESSAGE="$3"


case "$TYPE" in

info)

ICON="🟢"
TITLE_ICON="ℹ️"

;;

warning)

ICON="🟡"
TITLE_ICON="⚠️"

;;

error)

ICON="🔴"
TITLE_ICON="🚨"

;;

recovery)

ICON="🟢"
TITLE_ICON="✅"

;;

*)

ICON="ℹ️"
TITLE_ICON="📌"

;;

esac



event_log \
"$TYPE" \
"$TITLE" \
"$MESSAGE"



TEXT="
${ICON} FumetaOS ${TYPE^^}

${TITLE_ICON} ${TITLE}

${MESSAGE}

🕒 $(date '+%d/%m/%Y %H:%M')
"



echo "$TEXT" | "$BIN_DIR/telegram-notify"

}



###########################################################
# Tipos de evento
###########################################################

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
