# ssh-tips
Consejos y trucos de SSH

## Introducción

SSH (Secure Shell) es un protocolo de red criptográfico que proporciona un canal seguro sobre una red no confiable. Principalmente se utiliza para iniciar sesión de forma segura en sistemas informáticos remotos, pero también puede usarse para muchas otras tareas.

Este documento ofrece consejos prácticos para el uso diario de SSH, cubriendo configuraciones esenciales y casos de uso comunes. No pretende ser una especificación completa del protocolo, sino más bien una guía útil para administradores y desarrolladores.

## Historia

SSH fue desarrollado en 1995 por Tatu Ylönen como respuesta a un ataque de captura de contraseñas en la red de su universidad. Se diseñó para reemplazar de forma segura a Telnet, rlogin, rsh y rcp, que transmitían datos sin cifrar.

Hitos clave:
- **SSH-1** (1995): Protocolo original con vulnerabilidades de seguridad
- **SSH-2** (2006): Estándar actual con seguridad mejorada, convertido en estándar IETF (RFC 4251-4254)
- **OpenSSH** (1999): Implementación más utilizada, desarrollada por el proyecto OpenBSD

## Configuración del Servidor

### Instalación básica del servidor SSH

**Instalación (Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install openssh-server
```

**Instalación (RedHat/CentOS/Fedora):**
```bash
# Para RHEL/CentOS 8+ y Fedora:
sudo dnf install openssh-server
# Para RHEL/CentOS 7 y anteriores:
sudo yum install openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
```

### Consejos esenciales de configuración

El archivo principal de configuración es `/etc/ssh/sshd_config`. Algunas opciones clave:

**Deshabilitar acceso root:**
```
PermitRootLogin no
```

**Cambiar el puerto por defecto (seguridad por ocultación):**
```
Port 2222
```

**Habilitar autenticación por clave pública:**
```
PubkeyAuthentication yes
```

**Deshabilitar autenticación por contraseña (tras configurar las claves):**
```
PasswordAuthentication no
```

**Limitar acceso por usuario:**
```
AllowUsers usuario1 usuario2
```

**Tras los cambios, reiniciar el servicio SSH:**
```bash
sudo systemctl restart sshd
```

## Configuración del Cliente

### Consejos y trucos para el cliente SSH

**1. Archivo de configuración SSH (`~/.ssh/config`)**

Crea accesos directos para servidores frecuentes:
```
Host miservidor
    HostName ejemplo.com
    User usuario
    Port 2222
    IdentityFile ~/.ssh/id_rsa_personal
```

Ahora conecta simplemente así: `ssh miservidor`

**2. Generar claves SSH**

```bash
# Generar clave RSA (se recomienda 4096 bits)
ssh-keygen -t rsa -b 4096 -C "tu_email@ejemplo.com"

# Generar clave Ed25519 (moderna, recomendada)
ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"
```

**3. Copiar la clave pública al servidor**

```bash
ssh-copy-id usuario@servidor
# O especificar una clave:
ssh-copy-id -i ~/.ssh/id_rsa.pub usuario@servidor
```

**4. Agente SSH (evita repetir la contraseña)**

```bash
# Iniciar el agente
eval "$(ssh-agent -s)"

# Añadir clave
ssh-add ~/.ssh/id_rsa
```

**5. Redirección de puertos (Port Forwarding)**

**Redirección local** (acceder a un servicio remoto localmente):
```bash
ssh -L 8080:localhost:80 usuario@servidor-remoto
```
Ahora accede al puerto 80 del servidor remoto por localhost:8080

**Redirección remota** (exponer un servicio local en el remoto):
```bash
ssh -R 9090:localhost:3000 usuario@servidor-remoto
```

**Redirección dinámica (proxy SOCKS):**
```bash
ssh -D 1080 usuario@servidor-remoto
```

**6. Mantener la conexión viva**

Añade a `~/.ssh/config`:
```
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**7. Hosts intermedios (ProxyJump)**

Accede a un servidor a través de un host de salto/bastión:
```bash
ssh -J host-salto objetivo
```

O en el archivo de config:
```
Host objetivo
    HostName objetivo.interno
    ProxyJump host-salto
```

**8. SCP y SFTP para transferencias de archivos**

```bash
# Copiar archivo al remoto
scp archivo-local.txt usuario@remoto:/ruta/destino/

# Copiar desde el remoto
scp usuario@remoto:/ruta/archivo.txt ./directorio-local/

# Copiar directorio recursivamente
scp -r directorio-local usuario@remoto:/ruta/

# Sesión interactiva SFTP
sftp usuario@remoto
```

**9. Túneles SSH para bases de datos**

```bash
# Accede a MySQL/PostgreSQL remoto como si fuera local
ssh -L 3306:localhost:3306 usuario@servidor-bd
```

**10. Ejecutar comandos remotos**

```bash
# Ejecutar un solo comando
ssh usuario@servidor "ls -la /var/log"

# Ejecutar varios comandos
ssh usuario@servidor "cd /var/www && git pull && npm install"
```

## Uso Actual

SSH es omnipresente en la infraestructura TI moderna:

### DevOps y Computación en la Nube
- Administración remota de servidores
- Integración/Despliegue continuo (CI/CD)
- Orquestación de contenedores (Kubernetes, Docker)
- Gestión de instancias cloud (AWS, Azure, GCP)

### Flujos de trabajo de desarrollo
- Acceso a repositorios Git (GitHub, GitLab, Bitbucket)
- Entornos de desarrollo remoto
- Extensión VS Code Remote-SSH
- Depuración remota

### Administración de redes
- Transferencias seguras de archivos (SFTP, SCP)
- Configuración de dispositivos de red (routers, switches)
- Redirección y tunelización de puertos
- Alternativas a VPN

### Buenas prácticas de seguridad
- Usar claves SSH en vez de contraseñas
- Implementar fail2ban o similar contra ataques de fuerza bruta
- Rotación regular de claves
- Utilizar algoritmos robustos (Ed25519, RSA 4096 bits)
- Autenticación multifactor (Google Authenticator, Duo)

## Perspectivas Futuras

SSH sigue evolucionando con los requisitos modernos de seguridad:

### Tendencias emergentes

**Criptografía post-cuántica**
- Investigación en algoritmos resistentes a la computación cuántica
- Preparación ante amenazas cuánticas
- Enfoques híbridos que combinan algoritmos actuales y post-cuánticos

**Seguridad Zero Trust**
- Autenticación basada en certificados
- Credenciales de corta duración
- Control de acceso contextual

**Integración cloud-native**
- Mejor integración con proveedores de identidad en la nube
- Acceso SSH efímero
- Grabación de sesiones y auditoría

### Alternativas y complementos modernos

**Mosh (Mobile Shell)**
- Mejor rendimiento en conexiones de alta latencia
- Reconexión automática
- Eco local para mayor respuesta

**Tailscale/WireGuard**
- Alternativas modernas a VPN
- Redes mesh sin configuración
- Complementan SSH para acceso seguro

**Certificados SSH**
- Gestión centralizada de claves
- Expiración automática
- Control de acceso basado en roles

### Esfuerzos de estandarización

- Trabajo continuo de la IETF en mejoras del protocolo
- Algoritmos de seguridad mejorados
- Mejor soporte para métodos modernos de autenticación

## Recursos útiles

- [Documentación oficial de OpenSSH](https://www.openssh.com/)
- [RFCs del protocolo SSH](https://www.ietf.org/rfc/rfc4251.txt)
- [SSH Academy](https://www.ssh.com/academy/ssh)
- [OpenBSD OpenSSH FAQ](https://www.openbsd.org/faq/faq10.html)
- [ArchWiki: SSH](https://wiki.archlinux.org/title/SSH)

## Contribuir

¡No dudes en enviar issues o pull requests con consejos y trucos adicionales!

## Licencia

Este proyecto está licenciado bajo CC0 1.0 Universal - consulta el archivo LICENSE para más detalles.
