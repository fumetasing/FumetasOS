#!/bin/bash

###########################################################
# FumetaOS
# Installer
###########################################################

BASE="/opt/fumetaos"
PACKAGE="$BASE/install/package"
BACKUP_DIR="/mnt/datos/backups/fumetaos"


leer_version()
{

if [ -f "$PACKAGE/VERSION" ]; then

    FUMETAOS_VERSION=$(cat "$PACKAGE/VERSION")

else

    echo "❌ No existe versión en paquete"
    exit 20

fi

}


echo
echo "🖥️ FumetaOS Installer"
echo


leer_version


echo "Versión instalador: $FUMETAOS_VERSION"
echo


check_system()
{

echo "🔎 Comprobando sistema..."
echo


if [ -f /etc/os-release ]; then

    . /etc/os-release
    echo "✅ Sistema: $PRETTY_NAME"

else

    echo "❌ Sistema no detectado"
    exit 20

fi


echo "🏗️ Arquitectura: $(uname -m)"


if command -v systemctl >/dev/null; then

    echo "✅ Systemd disponible"

else

    echo "❌ Systemd no disponible"
    exit 20

fi


echo

if [ -d "$BASE" ]; then

    echo "✅ Directorio FumetaOS encontrado"

fi


echo

}


crear_backup_previo()
{

if [ ! -f "$BASE/VERSION" ]; then

    return

fi


echo
echo "⚠️ Instalación existente detectada"

mkdir -p "$BACKUP_DIR"


DATE=$(date +"%Y-%m-%d_%H-%M")

FILE="$BACKUP_DIR/fumetaos-preinstall-$DATE.tar.gz"


echo "💾 Creando backup previo..."


tar -czf "$FILE" \
-C "$BASE" \
bin core modules config VERSION 2>/dev/null


if [ $? -eq 0 ]; then

    echo "✅ Backup creado:"
    echo "$FILE"

else

    echo "❌ Error creando backup"
    exit 20

fi


echo

}


simular()
{

echo
echo "🧪 Modo simulación"
echo


echo "📁 Crearía:"
echo "$BASE/data"


echo

echo "📦 Copiaría:"
echo "✅ bin"
echo "✅ core"
echo "✅ modules"


if [ -f "$BASE/config/fumetaos.conf" ]; then

    echo "⏭️ config (existente, conservaría)"

else

    echo "✅ config"

fi


echo

echo "⚙️ Instalaría servicios:"
echo


for SERVICE in "$PACKAGE/services/"*
do

    echo "✅ $(basename "$SERVICE")"

done


echo

echo "⏱️ Activaría timers:"
echo

echo "✅ fumetaos-watch.timer"
echo "✅ fumetaos-history.timer"
echo "✅ fumetaos-history-clean.timer"
echo "✅ fumetaos-report.timer"
echo "✅ fumetaos-backup.timer"


echo

echo "🏷️ Versión final:"
echo "$FUMETAOS_VERSION"


echo

echo "✅ Simulación completada"
echo "❗ No se han realizado cambios"

echo

}


instalar()
{

echo
echo "🚀 Instalando FumetaOS $FUMETAOS_VERSION"
echo


if [ ! -d "$PACKAGE" ]; then

    echo "❌ Paquete no encontrado"
    exit 20

fi


crear_backup_previo


echo "📁 Creando estructura"

mkdir -p "$BASE/data"


echo "📦 Copiando binarios"

cp -r "$PACKAGE/bin" "$BASE/"


echo "📦 Copiando core"

cp -r "$PACKAGE/core" "$BASE/"


echo "📦 Copiando módulos"

cp -r "$PACKAGE/modules" "$BASE/"


if [ ! -f "$BASE/config/fumetaos.conf" ]; then

    echo "📦 Copiando configuración"

    cp -r "$PACKAGE/config" "$BASE/"

else

    echo "⏭️ Conservando configuración existente"

fi


echo "⚙️ Instalando servicios"

cp "$PACKAGE/services/"* /etc/systemd/system/


echo "🔄 Recargando systemd"

systemctl daemon-reload


echo
echo "⏱️ Activando timers"


for TIMER in \
fumetaos-watch.timer \
fumetaos-history.timer \
fumetaos-history-clean.timer \
fumetaos-report.timer \
fumetaos-backup.timer

do

    systemctl enable "$TIMER"

    systemctl start "$TIMER"

done


echo

echo "🏷️ Actualizando versión"

echo "$FUMETAOS_VERSION" > "$BASE/VERSION"


echo

echo "🩺 Doctor"

"$BASE/bin/fumetaos-doctor"


echo

echo "✅ FumetaOS instalado correctamente"
echo

}


case "$1" in

--check)

    check_system
    ;;


--dry-run)

    check_system
    simular
    ;;


--install)

    check_system
    instalar
    ;;


*)

    echo
    echo "Uso:"
    echo
    echo "fumetaos installer --check"
    echo "fumetaos installer --dry-run"
    echo "fumetaos installer --install"
    echo

    ;;

esac
