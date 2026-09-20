#!/bin/bash

###########################################################
# FumetaOS
# Monitor de seguridad
###########################################################

ERROR=0
UFW_BIN="/usr/sbin/ufw"
DOCKER_FIREWALL_SERVICE="fumetaos-docker-firewall.service"
DOCKER_CHAIN="FUMETAOS-DOCKER"

elevar_error() {
  if [ "$1" -gt "$ERROR" ]; then
    ERROR="$1"
  fi
}

obtener_interfaz_externa() {
  ip -4 route get 1.1.1.1 2>/dev/null |
    awk '{
      for (i = 1; i <= NF; i++) {
        if ($i == "dev") {
          print $(i + 1)
          exit
        }
      }
    }'
}

comprobar_proteccion_docker() {
  local interfaz

  echo

  if ! command -v iptables >/dev/null 2>&1; then
    echo "🔴 Protección Docker: iptables no disponible"
    elevar_error 20
    return
  fi

  if ! sudo -n systemctl is-enabled --quiet "$DOCKER_FIREWALL_SERVICE"; then
    echo "🔴 Protección Docker: servicio no habilitado"
    elevar_error 20
    return
  fi

  if ! sudo -n systemctl is-active --quiet "$DOCKER_FIREWALL_SERVICE"; then
    echo "🔴 Protección Docker: servicio inactivo"
    elevar_error 20
    return
  fi

  interfaz="$(obtener_interfaz_externa)"

  if [ -z "$interfaz" ] ||
     ! sudo -n iptables -w -C DOCKER-USER -j "$DOCKER_CHAIN" 2>/dev/null ||
     ! sudo -n iptables -w -C "$DOCKER_CHAIN" -i "$interfaz" -j DROP 2>/dev/null; then
    echo "🔴 Protección Docker: reglas incompletas"
    elevar_error 20
    return
  fi

  echo "🟢 Protección Docker activa"
  echo "🔒 LAN y Tailscale permitidos; Internet limitado a Transmission"
}

echo

###########################################################
# Firewall
###########################################################

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

###########################################################
# Políticas
###########################################################

POLICY="$(
  sudo -n "$UFW_BIN" status verbose 2>/dev/null |
    sed -n '/^Default:/ {p; q;}'
)"

if [ -n "$POLICY" ]; then
  echo "🔒 $POLICY"
fi

comprobar_proteccion_docker

exit "$ERROR"
