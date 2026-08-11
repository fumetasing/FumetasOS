#!/bin/sh

TORRENT_ID="${TR_TORRENT_ID}"

if [ -z "$TORRENT_ID" ]; then
    exit 1
fi

/usr/bin/transmission-remote \
    --auth "${USER}:${PASS}" \
    --torrent "$TORRENT_ID" \
    --remove

exit 0
