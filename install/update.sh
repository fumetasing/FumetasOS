#!/bin/bash

BASE="/opt/fumetaos"
PACKAGE="$BASE/install/package"

BACKUP_DIR="/mnt/datos/backups/fumetaos"
SYSTEM_BACKUP_DIR="/var/backups/fumetaos"

UPDATE_KEEP=3

FUMETAOS_TIMERS="
fumetaos-watch.timer
fumetaos-history.timer
fumetaos-history-clean.timer
fumetaos-report.timer
fumetaos-backup.timer
fumetaos-mac-backup.timer
fumetaos-recovery-backup.timer
"

leer_version()
{
    [ -f "$PACKAGE/VERSION" ] || {
        echo "❌ No existe versión en paquete"
        exit 20
    }

    FUMETAOS_VERSION=$(cat "$PACKAGE/VERSION")
}

limpiar_backups_update()
{
    mapfile -t BACKUPS < <(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            -name 'fumetaos-update-*.tar.gz' \
            -printf '%f\n' \
            | sort -r
    )

    for OLD_FILE in "${BACKUPS[@]:$UPDATE_KEEP}"
    do
        rm -f \
            "$BACKUP_DIR/$OLD_FILE" \
            "$SYSTEM_BACKUP_DIR/$OLD_FILE"

        echo "🗑️ Backup de update eliminado:"
        echo "$OLD_FILE"
    done
}

crear_backup()
{
    DATE=$(date +"%Y-%m-%d_%H-%M")
    FILE="$BACKUP_DIR/fumetaos-update-$DATE.tar.gz"
    SYSTEM_FILE="$SYSTEM_BACKUP_DIR/$(basename "$FILE")"

    echo "💾 Creando backup previo..."

    mkdir -p "$BACKUP_DIR" "$SYSTEM_BACKUP_DIR"

    tar -czf "$FILE" \
        -C "$BASE" \
        bin \
        core \
        modules \
        config \
        VERSION

    if [ $? -ne 0 ]; then
        echo "❌ Error creando backup"
        exit 20
    fi

    chown server:server "$FILE"

    cp "$FILE" "$SYSTEM_FILE"
    chown server:server "$SYSTEM_FILE"

    DATA_SUM=$(sha256sum "$FILE" | awk '{print $1}')
    SYSTEM_SUM=$(sha256sum "$SYSTEM_FILE" | awk '{print $1}')

    [ "$DATA_SUM" = "$SYSTEM_SUM" ] || {
        echo "❌ Las copias de update no coinciden"
        exit 20
    }

    limpiar_backups_update

    echo "✅ Backup creado:"
    echo "$FILE"
}

actualizar_directorio()
{
    SOURCE_DIR="$1"
    DEST_DIR="$2"
    LABEL="$3"

    echo "📦 Actualizando $LABEL"

    if [ -L "$DEST_DIR" ]; then
        echo "ℹ️ Se conserva el enlace simbólico: $DEST_DIR -> $(readlink -f "$DEST_DIR")"
        return 0
    fi

    rm -rf "$DEST_DIR"

    cp -r "$SOURCE_DIR" "$(dirname "$DEST_DIR")/" || {
        echo "❌ Error actualizando $LABEL"
        exit 20
    }
}

actualizar()
{
    echo
    echo "🔄 FumetaOS Update"
    echo

    leer_version

    echo "Versión destino: $FUMETAOS_VERSION"
    echo

    [ -d "$PACKAGE" ] || {
        echo "❌ Paquete no encontrado"
        exit 20
    }

    crear_backup

    actualizar_directorio "$PACKAGE/bin" "$BASE/bin" "binarios"
    actualizar_directorio "$PACKAGE/core" "$BASE/core" "core"
    actualizar_directorio "$PACKAGE/modules" "$BASE/modules" "módulos"

    echo "⚙️ Actualizando servicios"
    cp "$PACKAGE/services/"* /etc/systemd/system/

    echo "🔄 Recargando systemd"
    systemctl daemon-reload

    echo
    echo "⏱️ Actualizando timers"

    for TIMER in $FUMETAOS_TIMERS
    do
        systemctl enable "$TIMER"
        systemctl restart "$TIMER"
    done

    echo
    echo "🏷️ Actualizando versión"
    echo "$FUMETAOS_VERSION" > "$BASE/VERSION"

    echo
    echo "🩺 Ejecutando Doctor"
    "$BASE/bin/fumetaos-doctor"

    echo
    echo "✅ Actualización completada"
}

case "$1" in
    --update)
        actualizar
        ;;
    *)
        echo
        echo "Uso:"
        echo
        echo "fumetaos update"
        echo
        ;;
esac
