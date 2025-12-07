# Introducción - SSH Tips & Tricks

## ¿Qué es SSH más allá del acceso remoto?

SSH (Secure Shell) es un protocolo de red criptográfico desarrollado en 1995 por Tatu Ylönen. La mayoría lo conocemos como la herramienta para conectarnos a servidores remotos:

```bash
ssh user@servidor
```

Pero SSH es **mucho más** que eso. Es una navaja suiza para la conectividad segura.

## Breve Historia

- **SSH-1** (1995): Protocolo original creado para reemplazar Telnet, rlogin, rsh
- **SSH-2** (2006): Estándar actual (RFC 4251-4254) con seguridad mejorada
- **OpenSSH** (1999): Implementación de código abierto más utilizada

## Capacidades Avanzadas de SSH

### 🔀 Tunneling (Port Forwarding)

SSH puede crear túneles seguros para redirigir tráfico de red:

- **Local Forwarding:** Acceder a servicios remotos localmente
- **Remote Forwarding:** Exponer servicios locales remotamente
- **Dynamic Forwarding:** Crear un proxy SOCKS

### 🖥️ X11 Forwarding

Ejecutar aplicaciones gráficas en el servidor pero verlas en tu pantalla local.

### 🦘 ProxyJump

Saltar por múltiples bastiones para alcanzar servidores internos.

### 🔐 Autenticación por Claves

Acceso seguro sin contraseñas usando criptografía de clave pública.

## ¿Qué veremos hoy?

En esta ponencia demostraremos **3 casos prácticos** que muestran el poder real de SSH:

### 1️⃣ El Servidor que No Existe (12 min)

#### Túnel SSH Inverso

Acceder a un servidor web que está en tu equipo local, desde internet, sin tener IP pública.

Veremos como configurar *Systemd* para que mantenga el túnel levantado

**Técnicas:**

- Remote Port Forwarding (`ssh -R`)
- Gestión con systemd
- Crazy-bat (servidor web con netcat)

### 2️⃣ Salto de Bastiones + Servicio Privado (12 min)

#### ProxyJump + Port Forwarding Integrados

Saltar por un bastión Y acceder a un servicio web privado, todo en un solo comando.

**Técnicas:**

- ProxyJump (`ssh -J`)
- Local Port Forwarding (`ssh -L`)
- Configuración `~/.ssh/config`

### 3️⃣ La Ventana Mágica (10 min)

#### X11 Forwarding con Monitor CPU

Ver en tu pantalla local una aplicación gráfica corriendo en AWS. Ejecutar un stress test y ver la CPU dispararse en tiempo real.

**Técnicas:**

- X11 Forwarding (`ssh -X`)
- Aplicaciones gráficas remotas
- Monitorización visual

## Por qué importa

Estos no son trucos exóticos. Son herramientas prácticas para:

- **DevOps:** Acceder a servicios internos de forma segura
- **Desarrollo:** Testing con servicios remotos como si fueran locales
- **Seguridad:** Minimizar superficie de ataque (menos puertos abiertos)
- **Productividad:** Simplificar flujos de trabajo complejos

## Metodología de las Demostraciones

Cada caso incluirá:

✅ **Explicación del concepto** (2 min)  
✅ **Arquitectura visual** (1 min)  
✅ **Demostración en vivo** (7-8 min)  
✅ **Prueba empírica** (demostrar con hechos no con palabras)
✅ **Aplicaciones prácticas** (1 min)

Todos los recursos estarán disponibles en este repositorio:

- Código Terraform para replicar la infraestructura
- Scripts de configuración
- Documentación detallada
- Grabaciones *asciinema*

## ¿Listos?

Comencemos con el primer caso: **El Servidor que No Existe**

👉 **[Continuar al Caso 1: Túnel SSH Inverso](../02-reverse-tunnel/)**

---

## Recursos Adicionales

Para profundizar en SSH básico, consulta la [documentación completa de SSH Tips](../99-docs/README_tips_es.md) que cubre:

- Configuración de servidor y cliente
- Generación de claves
- SCP y SFTP
- Configuración `~/.ssh/config`
- Buenas prácticas de seguridad
