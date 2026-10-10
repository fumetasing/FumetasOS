# FumetaOS Changelog

## v2.4.27

### Added

- FileZilla aparece en el apartado Actualizaciones del informe, junto a Jellyfin y Transmission.
- La comprobación consulta el digest de la imagen LinuxServer publicada en Docker Hub y muestra la compilación instalada completa.
- Se distinguen los estados al día, actualización disponible y consulta no completada, sin descargar imágenes ni actualizar contenedores.
- La integración se incluye en el paquete de instalación y actualización mediante los directorios bin y modules existentes.

Validado con ocho pruebas aisladas y una consulta real: FileZilla 3.69.6-1-ls38 al día. Sin cambios de horarios, límites de borrado ni reinicios al publicar. La configuración privada de FileZilla no se publica.

## v2.4.26

### Fixed

- Time Capsule → Mac mantiene una sesión SSH persistente y una protección temporal contra reposo durante la copia.
- Las cuatro carpetas de destino se comprueban en una sola sesión, con reintentos limitados para fallos SSH de transporte.
- Los errores de conexión ya no se anuncian como carpetas inexistentes.
- La sesión temporal se cierra al finalizar o interrumpir la ejecución.
- Sin cambios de horarios ni límites: Time Capsule conserva 20 borrados por carpeta; el espejo general, 50 diarios con PS4 & PS5 exenta.

Validado mediante pruebas aisladas y simulaciones en el servidor, sin transferir ni borrar datos. Pendiente de comprobar una copia nocturna prolongada; no se certifica el despertar inicial de un Mac dormido.

## v2.4.20

### Fixed

- Corregido el contador preventivo de borrados de las copias espejo al Mac.
- La protección reconoce ahora las dos formas de salida utilizadas por rsync.
- Las copias se bloquean correctamente cuando se superarían los 50 borrados.
- Añadida una validación aislada del contador antes de publicar la corrección.


## v2.4.19

### Fixed

- Añadidos cinco reintentos antes de declarar inaccesible el USB del Mac.
- Evitados falsos avisos rojos provocados por fallos SSH transitorios en macOS 27.0.1.
- La comprobación realiza hasta seis intentos totales antes de afectar al estado general.



# Changelog

## v2.3.25

### Fixed

- Fixed FumetaOS backup script error handling.
- Fixed backup creation failure handling.
- Improved backup file ownership consistency.
- Backup files are now assigned to the `server` user and group.

## v2.3.24

### Fixed

- Fixed CasaOS crash caused by invalid SMB connection state.
- Improved stability after removing stale network mount references.
- Prevented SMB client state from breaking FumetaOS service operation.

## v2.3.23

### Improved

- Improved FumetaOS Watch service monitoring.
- Added warning state before reporting service failures.
- Prevented repeated Telegram alerts during persistent service outages.
- Improved service recovery detection.## v2.3.22

### Added

- Added application health monitoring.
- Added Jellyfin health validation.
- Added Transmission health validation.

### Improved

- Improved Telegram daily report formatting.
- Fixed duplicated Telegram report header.
- Improved application status reporting.

## v2.3.21

### Added

- Added application health monitoring.
- Added Docker health detection.
- Added custom health validation for Transmission.
- Added Jellyfin health validation.

### Improved

- Application reports now show real service health state.
- Jellyfin monitoring updated for CasaOS port mapping.

# 2.3.20

## Aplicaciones

- Corregida integración de Jellyfin con CasaOS.
- Migrada gestión de Jellyfin a instalación controlada por CasaOS.
- Corregidos montajes persistentes de biblioteca multimedia.
- Manteniendo configuración de usuario y datos mediante AppData.
- Actualizado Jellyfin a versión 10.11.10.

## Mantenimiento

- Eliminadas configuraciones antiguas de Jellyfin que podían interferir con CasaOS.
- Limpieza de definiciones duplicadas de aplicaciones.

# 2.3.0

## Nuevas funciones

- Añadido sistema de eventos persistente
- Añadido registro local de eventos del sistema
- Añadido visor de eventos FumetaOS Events
- Mejorado el sistema FumetaOS Watch
- Mejorado FumetaOS Doctor con nuevas comprobaciones


## Monitorización

- Añadida monitorización de timers FumetaOS
- Mejor integración entre Watch y Events
- Mejoras en diagnóstico del sistema
- Mejoras en comprobaciones de servicios


## Instalación y actualización

- Mejorado instalador FumetaOS
- Unificada gestión de timers en instalación y actualización
- Mejorado sistema de construcción de paquetes


## Interfaz

- Mejoras visuales en herramientas de consola
- Nuevos paneles de estado
- Preparación de vistas tipo dashboard


---

# 2.2.5

## Sistema

- Añadido gestor de servicios FumetaOS
- Añadido comando:
  - `fumetaos services`

## Monitorización

- Añadido sistema Watch
- Añadidas alertas Telegram
- Añadida monitorización de:
  - Servicios
  - Temperatura
  - Discos
  - Aplicaciones


## Dashboard

- Integración de servicios en Dashboard
- Mejoras en presentación del estado general


## Instalación

- Añadido generador de paquetes FumetaOS
- Mejoras en servicios systemd


---

# 2.2.0

## Base del sistema

- Nueva estructura modular FumetaOS
- Sistema de módulos de monitorización
- Gestión de aplicaciones Docker
- Configuración centralizada


## Monitorización

- Estado del sistema
- Memoria
- Temperaturas
- Discos
- SMART
- Aplicaciones


## Herramientas

- Dashboard principal
- Health check
- Doctor
- Backup
- History
- Update
