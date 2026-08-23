# FumetaOS Changelog


# Changelog

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
