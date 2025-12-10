# Introducción - SSH Tips & Tricks

## Prerequisitos: Configuración AWS para GitHub Actions

Configuración de la infraestructura AWS base.

### En GitHub

1. Crear `environment` `poc` en el repositorio GitHub con los siguientes secretos
   - `AWS_ACCESS_KEY_ID`: Credenciales AWS para configuración inicial
   - `AWS_SECRET_ACCESS_KEY`: Credenciales AWS para configuración inicial

2. Ejecutar el workflow **Setup AWS Requirements** desde GitHub Actions
   El workflow creará automáticamente:
   - Bucket S3 para Terraform state
   - Rol IAM con OIDC para GitHub Actions
   - Crea y añade los secretos en AWS

3. Añadir al `environment` `poc` el secreto `AWS_ROLE_ARN` que encontraremos en *AWS Secret Manager* , `TF_STATE_BUCKET`) al entorno `poc`

4. Eliminar las credenciales temporales (los workflows usarán OIDC) (opcional)

---

## ¿Qué es SSH más allá del acceso remoto?

SSH (Secure Shell) es un protocolo de red criptográfico desarrollado en 1995 por Tatu Ylönen. La mayoría lo conocemos como la herramienta para conectarnos a servidores remotos:

```bash
ssh user@servidor
```

Pero SSH es **mucho más** que eso. Es una herramienta muy versátil para la conectividad segura.

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

Saltar por múltiples equipos para alcanzar servidores remotos.

### 🔐 Autenticación por Claves

Acceso seguro sin contraseñas usando criptografía de clave pública.

## ¿Qué veremos hoy?

En esta ponencia demostraremos **3 casos prácticos** que muestran el poder real de SSH:

### 1️⃣ El Servidor que No Existe (12 min)

#### Túnel SSH Inverso

Acceder a un servidor web que está en tu equipo local, desde internet, sin tener IP pública.

**Técnicas:**

- Remote Port Forwarding (`ssh -R`)
- Crazy-bat (servidor web con netcat)

### 2️⃣ Salto de Servidores + Servicio Privado (12 min)

#### ProxyJump + Port Forwarding Integrados

Saltar por un servidor Y acceder a un servicio privado

**Técnicas:**

- ProxyJump (`ssh -J`)
- Local Port Forwarding (`ssh -L`)

### 3️⃣ La Ventana Mágica (10 min)

#### X11 Forwarding con Monitor CPU

Ver en tu pantalla local una aplicación gráfica corriendo en AWS. Ejecutar un stress test y ver la CPU dispararse en tiempo real.

**Técnicas:**

- X11 Forwarding (`ssh -X`)
- Aplicaciones gráficas remotas
- Monitorización visual

## A destacar

Estos no son trucos exóticos. Son herramientas prácticas para:

- **DevOps:** Acceder a servicios internos de forma segura
- **Desarrollo:** Testing con servicios remotos como si fueran locales
- **Seguridad:** Minimizar superficie de ataque (menos puertos abiertos)
- **Productividad:** Simplificar flujos de trabajo complejos

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
