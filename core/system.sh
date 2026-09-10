#!/bin/bash

###########################################################
# FumetaOS Core
# Funciones del sistema
###########################################################

###########################################################
# Cargar núcleo FumetaOS
###########################################################

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

###########################################################
# Configuración disco datos
###########################################################

DATA_MOUNT="${DATA_MOUNT:-/mnt/datos}"

###########################################################
# CPU
###########################################################

cpu_temp() {

    sensors | awk '/Package id 0:/ {
        gsub("\\+|°C","",$4)
        print int($4)
    }'

}

###########################################################
# RAM
###########################################################

ram_usage() {

    free | awk '/Mem:/ {
        printf "%.0f", $3/$2*100
    }'

}


ram_total() {

    TOTAL=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)

    if [ "$TOTAL" -le 2 ]; then
        echo "2 GB"
    elif [ "$TOTAL" -le 4 ]; then
        echo "4 GB"
    elif [ "$TOTAL" -le 8 ]; then
        echo "8 GB"
    elif [ "$TOTAL" -le 16 ]; then
        echo "16 GB"
    elif [ "$TOTAL" -le 32 ]; then
        echo "32 GB"
    elif [ "$TOTAL" -le 64 ]; then
        echo "64 GB"
    else
        echo "${TOTAL} GB"
    fi

}


ram_used() {

    free -m | awk '/Mem:/ {
        printf "%.0f MB", $3
    }'

}

###########################################################
# Disco
###########################################################

disk_usage() {

    df "$DATA_MOUNT" | awk 'NR==2 {
        gsub("%","",$5)
        print $5
    }'

}


disk_free() {

    df -h "$DATA_MOUNT" | awk 'NR==2 {
        print $4
    }'

}

###########################################################
# Actualizaciones
###########################################################

updates_available() {

    apt list --upgradable 2>/dev/null | tail -n +2 | wc -l

}
