# Recuperación completa de FumetaOS

Esta guía permite reconstruir FumetaOS en un servidor nuevo o tras un fallo del SSD del sistema.

La recuperación está pensada para Ubuntu Server AMD64/x86_64, la misma arquitectura que utiliza el servidor actual. Un Ubuntu ARM, como el de un Mac con Apple Silicon, sirve para consultar el repositorio Restic, pero no para validar una restauración completa de servicios, Docker y CasaOS.

## Qué protege la copia cifrada

La copia diaria de recuperación se ejecuta a las 04:00 y conserva:

- 14 copias diarias.
- 8 copias semanales.
- 12 copias mensuales.
- Configuración del sistema en `/etc`.
- Usuario y proyecto de FumetaOS en `/home/server`.
- Datos de root en `/root`.
- Datos de aplicaciones de CasaOS en `/DATA`.
- Instalación de FumetaOS en `/opt/fumetaos`.
- Scripts locales en `/usr/local`.
- Configuración de CasaOS en `/var/lib/casaos`.
- Tareas cron, si existen.
- Metadatos de recuperación: paquetes instalados, discos, montajes, servicios y estado de Docker.

No incluye:

- El contenido multimedia del segundo disco en `/mnt/datos`.
- El contenido de la Time Capsule, montado en `/DATA/TimeCapsule`.
- Una imagen arrancable completa del SSD ni los binarios del sistema operativo.

Por tanto, se instala primero un Ubuntu Server limpio y después se restauran configuración, datos de aplicaciones y paquetes.

## Elementos que deben existir fuera del servidor

Guarda estos datos también en tu gestor de contraseñas. Sin ellos no se podrá descifrar la copia tras perder el servidor:

- Contraseña de Restic, guardada actualmente en `/etc/fumetaos/restic-password`.
- Ubicación del repositorio: `/mnt/datos/backups/fumetaos/recovery-repo`.
- Usuario del servidor: `server`.
- Dirección IP prevista: `192.168.1.3`.
- Repositorio de FumetaOS y rama: `feature/system-manager-v2`.
- Credenciales de la Time Capsule, si se desea restaurar su montaje AFP.
- Clave SSH usada para la copia espejo al Mac.

No guardes la contraseña de Restic dentro de este repositorio Git.

## Comprobar que existen copias utilizables

En el servidor operativo:

```bash
sudo /opt/fumetaos/bin/fumetaos-recovery-backup list
sudo /opt/fumetaos/bin/fumetaos-recovery-backup stats
sudo /opt/fumetaos/bin/fumetaos-recovery-backup verify
