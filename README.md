# 🖥️ FumetaOS

> Framework de administración para servidores Linux.

FumetaOS es un framework de administración diseñado para simplificar la gestión de servidores Linux mediante una única interfaz de línea de comandos.

Actualmente está orientado a servidores domésticos y pequeños servidores profesionales basados en Ubuntu.

---

## Características

- 🩺 Diagnóstico del sistema
- 📊 Estado del servidor
- ❤️ Monitorización de recursos
- 👀 Vigilancia automática
- 📜 Histórico de eventos
- 💾 Copias de seguridad
- 📦 Gestión de aplicaciones Docker
- 🔔 Notificaciones mediante Telegram
- 🔄 Sistema de actualización integrado

---

## Requisitos

- Ubuntu Server
- systemd
- Docker
- Docker Compose

---

## Instalación

Actualmente la instalación se realiza mediante:

```bash
sudo ./install/install.sh
```

---

## Comandos disponibles

```bash
fumetaos

fumetaos doctor
fumetaos status
fumetaos health
fumetaos watch
fumetaos history
fumetaos backup
fumetaos version

fumetaos app list
```

---

## Filosofía

FumetaOS se basa en cinco principios fundamentales:

- Simplicidad
- Modularidad
- Seguridad
- Automatización
- Mantenibilidad

---

## Arquitectura

```text
Repositorio Git
        │
        ▼
install.sh
        │
        ▼
/opt/fumetaos
        │
        ▼
Servidor
```

---

## Roadmap

### Versión 2.3

- Gestor de aplicaciones
- Integración con Docker Compose
- Nueva arquitectura basada en Git

### Versión 2.4

- Gestión de red
- Firewall
- DNS

### Versión 2.5

- Gestión avanzada del almacenamiento
- Snapshots
- SMART avanzado

### Versión 3.0

- Interfaz Web

---

## Licencia

MIT License

---

**Desarrollado por Fumeta.**
