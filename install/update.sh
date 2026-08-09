#!/bin/bash

###########################################################
# FumetaOS
# Update
###########################################################

BASE="/opt/fumetaos"
PACKAGE="$BASE/install/package"
BACKUP_DIR="/mnt/datos/backups/fumetaos"


FUMETAOS_TIMERS="
fumetaos-watch.timer
fumetaos-history.timer
fumetaos-history-clean.timer
fumetaos-report.timer
fumetaos-backup.timer
"



leer_version()
{

if [ -f "$PACKAGE/VERSION" ]; then

    FUMETAOS_VERSION=$(cat "$PACKAGE/VERSION")

else

    echo "❌ No existe versión en paquete"
    exit 20

fi

}



crear_backup()
{

DATE=$(date +"%Y-%m-%d_%H-%M")

FILE="$BACKUP_DIR/fumetaos-update-$DATE.tar.gz"


echo "💾 Creando backup previo..."


mkdir -p "$BACKUP_DIR"


tar -czf "$FILE" \
-C "$BASE" \
bin core modules config VERSION


if [ $? -eq 0 ]; then

    echo "✅ Backup creado:"
    echo "$FILE"

else

    echo "❌ Error creando backup"
    exit 20

fi


}



actualizar()
{

echo
echo "🔄 FumetaOS Update"
echo


leer_version


echo "Versión destino: $FUMETAOS_VERSION"
echo


if [ ! -d "$PACKAGE" ]; then

    echo "❌ Paquete no encontrado"
    exit 20

fi



crear_backup



echo "📦 Actualizando binarios"
cp -r "$PACKAGE/bin" "$BASE/"


echo "📦 Actualizando core"
cp -r "$PACKAGE/core" "$BASE/"


echo "📦 Actualizando módulos"
cp -r "$PACKAGE/modules" "$BASE/"


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
