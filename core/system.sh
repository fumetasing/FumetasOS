#!/bin/bash

###########################################################
# FumetaOS Core
# Funciones del sistema
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
	sensors |
		awk '/Package id 0:/ {
            gsub("\\+|°C", "", $4)
            print int($4)
        }'
}

###########################################################
# RAM
###########################################################

ram_metrics() {
	free |
		awk '/Mem:/ {
            printf "%.0f %.0f %.0f\n", $3 / $2 * 100, $3 / 1024, $2 / 1024
        }'
}

ram_total_label() {
	local total_mb="$1"
	local total_gb

	total_gb=$(((total_mb + 512) / 1024))

	if [ "$total_gb" -le 2 ]; then
		echo "2 GB"
	elif [ "$total_gb" -le 4 ]; then
		echo "4 GB"
	elif [ "$total_gb" -le 8 ]; then
		echo "8 GB"
	elif [ "$total_gb" -le 16 ]; then
		echo "16 GB"
	elif [ "$total_gb" -le 32 ]; then
		echo "32 GB"
	elif [ "$total_gb" -le 64 ]; then
		echo "64 GB"
	else
		echo "${total_gb} GB"
	fi
}

ram_usage() {
	free |
		awk '/Mem:/ {
            printf "%.0f", $3 / $2 * 100
        }'
}

ram_total() {
	local total_mb

	total_mb="$(
		awk '/MemTotal/ {
            printf "%.0f", $2 / 1024
        }' /proc/meminfo
	)"

	ram_total_label "$total_mb"
}

ram_used() {
	free -m |
		awk '/Mem:/ {
            printf "%.0f MB", $3
        }'
}

###########################################################
# Disco
###########################################################

disk_usage() {
	df "$DATA_MOUNT" |
		awk 'NR == 2 {
            gsub("%", "", $5)
            print $5
        }'
}

disk_free() {
	df -h "$DATA_MOUNT" |
		awk 'NR == 2 {
            print $4
        }'
}

###########################################################
# Actualizaciones
###########################################################

updates_available() {
	local simulation

	if ! simulation="$(
		apt-get \
			--simulate \
			--quiet=2 \
			dist-upgrade \
			2>/dev/null
	)"; then
		return 1
	fi

	awk '
        $1 == "Inst" {
            updates++
        }

        END {
            print updates + 0
        }
    ' <<<"$simulation"
}
