# Perfil DNS de Movistar para O2/Movistar

Este despliegue utiliza `80.58.61.250` y `80.58.61.254` como resolutores públicos. Se trata de una elección local para una conexión de O2/Movistar, no de un valor universal recomendado para todas las instalaciones de FumetaOS.

## Configuración persistente

- **Ubuntu:** ambas direcciones en `nameservers.addresses` de la interfaz de salida de Netplan. El perfil opcional `config/systemd/resolved.conf.d/90-fumetaos-dns.conf` fija las mismas direcciones como respaldo de systemd-resolved. En este despliegue se instala en `/etc/systemd/resolved.conf.d/90-fumetaos-dns.conf`.
- **Docker:** ambas direcciones en la clave `dns` de `/etc/docker/daemon.json`, conservando las demás opciones. Un servicio con DNS explícitas en Compose, como Transmission, debe usar las mismas direcciones. Los contenedores existentes deben comprobarse después de aplicar el cambio: cambiar el archivo del daemon no basta para demostrar qué están utilizando.
- **AdGuard Home:** ambas direcciones como upstream y bootstrap. Se conservan protección, filtros, reescrituras y configuración de clientes. Revisar también fallback y cualquier cliente con upstream propio.
- **macOS:** revisar las DNS manuales de cada servicio activo. Los servicios automáticos heredan las del DHCP de la red a la que se conecten; no se puede prometer que usen Movistar en cualquier red externa.
- **Router:** comprobar los DNS de la conexión WAN y los que entrega el DHCP general. No sustituir parámetros de grupos reservados del operador o de televisión por los del grupo general.
- **Tailscale:** se conservan MagicDNS y sus dominios internos. Cuando se usa el nodo de salida, revisar los resolutores del servidor. Sin nodo de salida, la resolución puede seguir la configuración local del dispositivo y de la red.

El perfil de respaldo es opcional: el instalador y actualizador no lo copian automáticamente a `/etc`. Cambiar el proveedor debe ser una decisión explícita del administrador.

## Comprobaciones

1. `resolvectl dns` y `resolvectl status` muestran los servidores públicos de Ubuntu y separan los dominios internos de Tailscale.
2. Revisar `/etc/resolv.conf` dentro de cada contenedor. `127.0.0.11` es el intermediario interno de Docker; sus servidores externos deben coincidir con los elegidos. `127.0.0.53` es el intermediario local de systemd-resolved, no otro proveedor.
3. Comprobar upstream, bootstrap, fallback y clientes especiales en AdGuard. Validar una consulta real al servicio.
4. En macOS, `scutil --dns` muestra los resolutores efectivos. Una entrada `.local` de mDNS o los nombres internos de Tailscale no deben enviarse a un DNS público.
5. Revisar las opciones de DNS seguro de navegadores, perfiles DNS/VPN e iCloud Private Relay en cada dispositivo si se necesita conocer también esa capa.

Una configuración correcta del sistema no impone el proveedor a una aplicación que use su propio DoH, DoT o resolver integrado. Este despliegue no añade reglas de interceptación ni bloquea esas alternativas. Tampoco convierte las consultas DNS ordinarias en consultas cifradas.

## Aplicación y recuperación

Comparar configuraciones por su significado: el orden de las variables de entorno y de los montajes puede variar al recrear un contenedor. Deben seguir comprobándose los valores, las rutas, los permisos, la imagen y los ajustes efectivos.

Antes de aplicar cambios generales de Docker, verificar que no hay copias en curso y que los montajes requeridos están disponibles. Habrá un corte de las aplicaciones si se reinicia Docker. Conservar un respaldo privado hasta confirmar resolución, arranque y salud de los servicios; retirarlo únicamente por decisión del administrador.

No subir al repositorio configuraciones reales con credenciales, historiales de consultas DNS ni inspecciones completas de contenedores.

## Referencias

- [DNS oficiales de Movistar](https://comunidad.movistar.es/kb/Router/%C2%BFcuales-son-las-dns-de-movistar/3861876)
- [systemd-resolved: DNS y FallbackDNS](https://www.freedesktop.org/software/systemd/man/latest/resolved.conf.html)
- [DNS en Tailscale](https://tailscale.com/docs/reference/dns-in-tailscale)
