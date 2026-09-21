#!/bin/bash

ERROR=0
UFW_BIN="/usr/sbin/ufw"
DOCKER_STATUS="/opt/fumetaos/bin/fumetaos-docker-firewall-status"

elevar_error() {
  if [ "$1" -gt "$ERROR" ]; then
    ERROR="$1"
  fi
}

comprobar_proteccion_docker() {
  echo

  if [ ! -x "$DOCKER_STATUS" ]; then
    echo "🔴 Protección Docker: verificador no disponible"
    elevar_error 20
    return
  fi

  if ! sudo -n "$DOCKER_STATUS" >/dev/null 2>&1; then
    echo "🔴 Protección Docker: no está activa o no se puede verificar"
    elevar_error 20
    return
  fi

  echo "🟢 Protección Docker activa"
  echo "🔒 LAN y Tailscale permitidos; Internet limitado a Transmission"
}

echo

if [ ! -x "$UFW_BIN" ]; then
  echo "🔴 Firewall UFW no instalado"
  exit 20
fi

if ! sudo -n "$UFW_BIN" status >/dev/null 2>&1; then
  echo "🔴 No se puede consultar el Firewall UFW"
  exit 20
fi

STATUS="$(sudo -n "$UFW_BIN" status 2>/dev/null | sed -n '1p')"

if echo "$STATUS" | grep -q "active"; then
  echo "🟢 Firewall UFW activo"
else
  echo "🔴 Firewall UFW inactivo"
  elevar_error 20
fi

POLICY="$(
  sudo -n "$UFW_BIN" status verbose 2>/dev/null |
    sed -n '/^Default:/ {p; q;}'
)"

if [ -n "$POLICY" ]; then
  echo "🔒 $POLICY"
fi

comprobar_proteccion_docker

exit "$ERROR"
