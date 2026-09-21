#!/bin/bash

###########################################################
# FumetaOS
# Monitor de servicios
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/../../core/services.sh"

WATCH=0
ERROR=0

if [ "${1:-}" = "--watch" ]; then
  WATCH=1
fi

elevar_error() {
  if [ "$1" -gt "$ERROR" ]; then
    ERROR="$1"
  fi
}

registros_casaos() {
  if [ "$(id -u)" -eq 0 ]; then
    journalctl -u casaos.service --since "24 hours ago" --no-pager
  else
    sudo -n /opt/fumetaos/bin/fumetaos-casaos-journal
  fi
}

comprobar_estabilidad_casaos() {
  local registros
  local fallos

  if ! registros="$(registros_casaos 2>/dev/null)"; then
    if [ "$WATCH" -eq 0 ]; then
      echo "🟡 CasaOS: no se pudo revisar su estabilidad"
    else
      echo "No se pudo revisar la estabilidad de CasaOS"
    fi

    elevar_error 10
    return
  fi

  fallos="$(
    printf '%s\n' "$registros" |
      grep -Ec \
        'fatal error:|found pointer to free object|found bad pointer in Go heap' ||
      true
  )"

  if [ "$fallos" -eq 0 ]; then
    if [ "$WATCH" -eq 0 ]; then
      echo "🟢 CasaOS: sin fallos detectados en las últimas 24 horas"
    fi
  else
    if [ "$WATCH" -eq 0 ]; then
      echo "🟡 CasaOS: $fallos fallos detectados en las últimas 24 horas"
    else
      echo "CasaOS: $fallos fallos detectados en las últimas 24 horas"
    fi

    elevar_error 10
  fi
}

for service in $SYSTEM_SERVICES; do
  if unit_is_active "$service"; then
    if [ "$WATCH" -eq 0 ]; then
      echo "✅ $service"
    fi

    if [ "$service" = "casaos" ]; then
      comprobar_estabilidad_casaos
    fi
  else
    if [ "$WATCH" -eq 0 ]; then
      echo "🚨 $service"
    else
      echo "Servicio detenido: $service"
    fi

    elevar_error 20
  fi
done

exit "$ERROR"
