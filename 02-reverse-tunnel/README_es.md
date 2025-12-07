# Caso 1: El Servidor que No Existe

## 🎯 Objetivo

Demostrar cómo exponer un servicio web local a internet sin tener IP pública, usando túneles SSH inversos.

## 📋 Concepto

Servidor web accesible desde internet que físicamente está en tu equipo local, sin IP pública.

## 🔧 Técnicas SSH Demostradas

- **Remote Port Forwarding** (`ssh -R`): Túnel inverso desde equipo local hacia servidor público
- **Gestión de túneles con systemd**: Mantener el túnel activo y auto-recuperable
- **Servidor web con netcat**: Uso del proyecto [crazy-bat](https://github.com/antoniollv/crazy-bat)

## 🏗️ Arquitectura

```text
Internet → AWS EC2 (IP pública) ← SSH Tunnel ← Equipo Local (crazy-bat)
          puerto 8080              reverse      puerto 8080
```

### Componentes

1. **Equipo Local**
   - Ejecuta crazy-bat (servidor web con netcat en puerto 8080)
   - Inicia túnel SSH inverso hacia EC2
   - Gestión del túnel mediante systemd

2. **AWS EC2 (Bastion)**
   - Instancia t2.micro con IP pública
   - Recibe conexión SSH desde equipo local
   - Expone puerto 8080 a internet
   - Security Group: permite tráfico en puerto 8080

3. **Audiencia**
   - Accede a `http://<ec2-public-ip>:8080`
   - Ve el contenido servido desde el equipo local del presentador

## 🚀 Demostración Paso a Paso

### 1. Preparación (Pre-demostración)

**En equipo local:**

```bash
# Clonar crazy-bat
git clone https://github.com/antoniollv/crazy-bat.git
cd crazy-bat

# Iniciar el servidor
./crazy-bat.sh
```

**Verificar que funciona localmente:**

```bash
curl http://localhost:8080
```

### 2. Desplegar Infraestructura AWS

```bash
# Ejecutar GitHub Actions workflow o manualmente con Terraform
cd 02-reverse-tunnel/terraform
terraform init
terraform apply
```

**Recursos creados:**

- EC2 t2.micro con IP pública
- Security Group (SSH puerto 22, HTTP puerto 8080)
- Elastic IP (opcional para IP estática)

### 3. Configurar Túnel SSH con Systemd

**Crear archivo de servicio:** `/etc/systemd/system/reverse-tunnel.service`

```ini
[Unit]
Description=SSH Reverse Tunnel to AWS EC2
After=network.target

[Service]
Type=simple
User=<tu-usuario>
ExecStart=/usr/bin/ssh -N -R 8080:localhost:8080 -o ServerAliveInterval=60 -o ServerAliveCountMax=3 ec2-user@<ec2-public-ip> -i /path/to/ssh-key.pem
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Activar y arrancar el servicio:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable reverse-tunnel.service
sudo systemctl start reverse-tunnel.service
sudo systemctl status reverse-tunnel.service
```

### 4. Presentación en Vivo

**Mostrar a la audiencia:**

1. **Acceso público:** Compartir URL `http://<ec2-public-ip>:8080`
2. **Verificación local:** Mostrar que crazy-bat está corriendo en `localhost:8080`
3. **Túnel activo:** `sudo systemctl status reverse-tunnel.service`

**Prueba empírica:**

```bash
# Detener el servicio local
sudo systemctl stop crazy-bat  # O detener el proceso manualmente

# La audiencia verá que la web pública deja de responder
# Reiniciar el servicio y la web vuelve a funcionar
sudo systemctl start crazy-bat
```

### 5. Explicaciones Técnicas Durante la Demo

- **¿Cómo funciona `-R 8080:localhost:8080`?**
  - El servidor EC2 escucha en su puerto 8080
  - Cuando alguien se conecta, SSH redirige el tráfico al puerto 8080 del equipo local
  
- **¿Por qué systemd?**
  - Auto-recuperación si la conexión SSH se pierde
  - Logging centralizado (`journalctl -u reverse-tunnel`)
  - Gestión consistente como cualquier otro servicio del sistema

- **Alternativa avanzada:** Mencionar `autossh` para entornos de producción (documentado en `99-docs/README_autossh_es.md`)

## 📦 Recursos Necesarios

### AWS

- **EC2 Instance:** t2.micro (Free Tier elegible)
- **Security Group:**
  - Inbound: Puerto 22 (SSH desde tu IP)
  - Inbound: Puerto 8080 (HTTP desde 0.0.0.0/0)
- **Key Pair:** Para autenticación SSH

### Local

- **crazy-bat:** [https://github.com/antoniollv/crazy-bat](https://github.com/antoniollv/crazy-bat)
- **SSH client:** OpenSSH
- **systemd:** Para gestión del túnel (incluido en Linux moderno)

## 🎬 Grabación con Asciinema

Crear grabación de respaldo para cada paso:

```bash
# Grabar configuración del túnel
asciinema rec demo-reverse-tunnel-setup.cast

# Grabar la demostración completa
asciinema rec demo-reverse-tunnel-live.cast
```

## ⚠️ Troubleshooting

### El túnel no se establece

```bash
# Verificar conectividad SSH básica
ssh -i /path/to/key.pem ec2-user@<ec2-public-ip>

# Probar túnel manualmente
ssh -v -N -R 8080:localhost:8080 ec2-user@<ec2-public-ip> -i /path/to/key.pem
```

### La web no es accesible desde internet

```bash
# Verificar que EC2 está escuchando en 8080
ssh ec2-user@<ec2-public-ip> 'sudo netstat -tlnp | grep 8080'

# Verificar Security Group en AWS Console
# Asegurar que GatewayPorts está habilitado en sshd_config del EC2
```

### El servicio systemd falla

```bash
# Ver logs detallados
sudo journalctl -u reverse-tunnel.service -f

# Verificar permisos de la clave SSH
chmod 600 /path/to/key.pem
```

## 🔗 Referencias

- [Documentación de crazy-bat](https://github.com/antoniollv/crazy-bat)
- [SSH Remote Port Forwarding](https://www.ssh.com/academy/ssh/tunneling/example)
- [systemd Service Files](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Alternativa con autossh](../99-docs/README_autossh_es.md)

## 📝 Notas para el Presentador

- **Tiempo estimado:** 12 minutos
- **Prerequisitos verificados antes de la demo:**
  - ✅ Infraestructura AWS desplegada
  - ✅ crazy-bat funcionando localmente
  - ✅ Túnel SSH activo y verificado
  - ✅ URL pública compartida con la audiencia
- **Backup plan:** Grabación asciinema lista para reproducir si falla la demo en vivo
