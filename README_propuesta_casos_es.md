# Propuesta de Casos para Ponencia SSH

## 📊 Análisis del Material Recopilado

### Material actual en el repositorio

1. **README.md** - Guía general SSH (buena base teórica)
2. **autossh.md** - Configuración de túneles persistentes
3. **error_en_la_conexión_SSH.md** - Solución algoritmos deprecados
4. **tunelssh_con_usuario_enjaulado.md** - Usuario chroot + túnel SSH
5. **crazy-bat** (repositorio externo) - Servidor web con netcat

### Evaluación para ponencia (40 min)

✅ **Material aprovechable:**

- Túneles SSH con autossh (muy práctico)
- Usuario enjaulado (interesante para seguridad)
- Algoritmos deprecados (útil pero poco llamativo)

⚠️ **Necesita adaptación:**

- Documentación muy técnica para demo rápida
- Falta integración con crazy-bat
- Sin POCs automatizados con Terraform/AWS

## 💡 Propuestas de Casos Llamativos

### 🔥 CASOS PRINCIPALES (Recomendados para la ponencia)

#### CASO 1 SELECCIONADO: "El Servidor que No Existe" - Túnel Inverso con Crazy-Bat + Systemd

**Clasificación:** ⭐⭐⭐ IMPACTO ALTO  
**Tiempo estimado:** 12 minutos  
**Dificultad técnica:** Media  
**Factor WOW:** Muy Alto

**Concepto:**

Demostrar un servidor web accesible desde internet que físicamente está en tu laptop, sin IP pública, usando túnel SSH inverso, systemd y crazy-bat.

**Arquitectura POC:**

- EC2 en AWS con IP pública (servidor bastion)
- Tu equipo local ejecuta crazy-bat (servidor netcat en puerto 8080)
- Túnel SSH inverso: laptop → EC2 (remote port forwarding) gestionado por systemd
- La audiencia accede a `http://ec2-public-ip:8080` y ve la página de crazy-bat
- **Prueba empírica:** Matas el servicio en tu laptop y la web se cae → demuestras que estaba en local

**Demostración paso a paso:**

1. **Crear servicio systemd para el túnel SSH:**

   ```bash
   # Crear archivo: ~/.config/systemd/user/ssh-reverse-tunnel.service
   [Unit]
   Description=SSH Reverse Tunnel to AWS for Crazy-Bat
   After=network.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/ssh -N -R 8080:localhost:8080 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes ec2-user@ec2-public-ip
   Restart=always
   RestartSec=5

   [Install]
   WantedBy=default.target
   ```

2. **Activar y arrancar el servicio:**

   ```bash
   # Recargar systemd
   systemctl --user daemon-reload

   # Habilitar para inicio automático
   systemctl --user enable ssh-reverse-tunnel.service

   # Iniciar servicio
   systemctl --user start ssh-reverse-tunnel.service

   # Ver estado
   systemctl --user status ssh-reverse-tunnel.service
   ```

3. **Iniciar crazy-bat en local:**

   ```bash
   docker run -p 8080:8080 -e BAT_SAY="¡Estoy en mi laptop!" --rm -d crazybat:snapshot
   ```

4. **Demo para la audiencia:**

   ```bash
   # La audiencia accede a:
   http://ec2-public-ip:8080

   # Momento sorpresa: parar crazy-bat local
   docker stop <container-id>
   # Refrescar navegador → Error 502/503

   # Volver a iniciar
   docker run -p 8080:8080 -e BAT_SAY="¡He vuelto!" --rm -d crazybat:snapshot
   # Refrescar navegador → Funciona de nuevo
   ```

**Configuración previa en EC2 (`/etc/ssh/sshd_config`):**

```config
GatewayPorts yes  # Permitir que el puerto 8080 sea accesible desde fuera
```

**Recursos AWS necesarios:**

- 1 EC2 t2.micro (Amazon Linux 2)
- Security Group: puerto 22 (SSH) y 8080 (HTTP)
- IP elástica

**Mejora para producción - Mención rápida:**

```text
"En producción, en lugar de systemd básico usaríamos autossh, que es más 
inteligente para manejar reconexiones en caso de problemas de red. 
Ejemplo de configuración disponible en el repositorio (README_autossh.md)"
```

**Ventaja de systemd básico:**

- No requiere paquetes adicionales
- Integrado en el sistema
- Fácil de gestionar con systemctl
- Reinicio automático con `Restart=always`

**Por qué sorprenderá:**

Viola la intuición de "necesito IP pública para servir contenido web". Demuestra el poder de los túneles inversos de forma visual y comprensible. El uso de systemd muestra profesionalismo (infraestructura como servicio).

---

**Clasificación:** ⭐⭐⭐ IMPACTO ALTO  
**Tiempo estimado:** 8-10 minutos  
**Dificultad técnica:** Media  
**Factor WOW:** Muy Alto

**Concepto:**

Demostrar un servidor web accesible desde internet que físicamente está en tu laptop, sin IP pública, usando túnel SSH inverso y crazy-bat.

**Arquitectura POC:**

- EC2 en AWS con IP pública (servidor bastion)
- Tu equipo local ejecuta crazy-bat (servidor netcat en puerto 8080)
- Túnel SSH inverso: laptop → EC2 (remote port forwarding)
- La audiencia accede a `http://ec2-public-ip:8080` y ve la página de crazy-bat
- **Prueba empírica:** Matas el servicio en tu laptop y la web se cae → demuestras que estaba en local

**Comandos clave:**

```bash
# En tu laptop
ssh -R 8080:localhost:8080 user@ec2-public-ip

# crazy-bat corriendo localmente
docker run -p 8080:8080 -e BAT_SAY="¡Estoy en mi laptop!" crazybat:snapshot
```

**Recursos AWS necesarios:**

- 1 EC2 t2.micro (Amazon Linux 2)
- Security Group: puerto 22 (SSH) y 8080 (HTTP)
- IP elástica

**Por qué sorprenderá:**

Viola la intuición de "necesito IP pública para servir contenido web". Demuestra el poder de los túneles inversos de forma visual y comprensible.

**Variante avanzada (si hay tiempo):**

Usar autossh para mantener el túnel persistente incluso si la conexión se cae.

---

#### CASO 2: "El Salto del Canguro" - ProxyJump Multi-Hop

**Clasificación:** ⭐⭐⭐ IMPACTO ALTO  
**Tiempo estimado:** 8-10 minutos  
**Dificultad técnica:** Media-Alta  
**Factor WOW:** Alto

**Concepto:**

Acceder a un servidor ultra-privado (sin IP pública, sin acceso directo) saltando por 2-3 bastion hosts con un solo comando SSH.

**Arquitectura POC:**

- **EC2-Public (Bastion 1):** IP pública, en subnet pública
- **EC2-Private-1 (Bastion 2):** Solo IP privada, en subnet privada, accesible desde Bastion 1
- **EC2-Private-2 (Servidor final):** Solo IP privada, en subnet ultra-privada, accesible solo desde Bastion 2

**Demostración:**

```bash
# Comando tradicional (complejo)
ssh -J user@bastion1 user@bastion2
ssh -J user@bastion1,user@bastion2 user@ultra-private

# Con configuración en ~/.ssh/config (simple)
ssh ultra-private
```

**Configuración ~/.ssh/config:**

```config
Host bastion1
    HostName 54.xxx.xxx.xxx
    User ec2-user
    IdentityFile ~/.ssh/aws-key.pem

Host bastion2
    HostName 10.0.1.50
    User ec2-user
    ProxyJump bastion1
    IdentityFile ~/.ssh/aws-key.pem

Host ultra-private
    HostName 10.0.2.100
    User ec2-user
    ProxyJump bastion1,bastion2
    IdentityFile ~/.ssh/aws-key.pem
```

**Demo adicional:**

```bash
# Copiar archivo atravesando los 3 servidores
scp -J bastion1,bastion2 local-file.txt ultra-private:/tmp/

# Ejecutar comando remoto
ssh ultra-private "hostname && ip addr"
```

**Recursos AWS necesarios:**

- 3 EC2 t2.micro
- VPC con 3 subnets (pública, privada-1, privada-2)
- Security Groups configurados para permitir SSH entre ellos
- 1 IP elástica (solo para bastion1)

**Por qué sorprenderá:**

Muestra la simplicidad de SSH moderno vs topologías de red complejas. Es extremadamente útil para entornos cloud reales.

---

#### CASO 2 ACTUALIZADO: "El Salto del Canguro" - ProxyJump + Port Forwarding Integrados

**Clasificación:** ⭐⭐⭐ IMPACTO ALTO  
**Tiempo estimado:** 12 minutos  
**Dificultad técnica:** Media-Alta  
**Factor WOW:** Alto

**Concepto:**

Demostración integrada que combina ProxyJump (saltar por bastiones) con Port Forwarding (acceder a servicio privado). Un solo flujo que muestra ambas técnicas trabajando juntas.

**Arquitectura POC:**

- **EC2-Public (Bastion):** IP pública, en subnet pública
- **EC2-Private (Servidor con servicio):** Solo IP privada, en subnet privada, ejecuta nginx o crazy-bat
- Acceder al servicio web privado saltando por el bastion

**Demostración integrada:**

```bash
# Saltar por bastion Y hacer port forwarding en un solo comando
ssh -L 8080:10.0.1.50:80 -J ec2-user@bastion-public ec2-user@private-server

# Ahora acceder en navegador local
http://localhost:8080
```

**Configuración ~/.ssh/config optimizada:**

```config
Host bastion
    HostName 54.xxx.xxx.xxx
    User ec2-user
    IdentityFile ~/.ssh/aws-key.pem

Host private-web
    HostName 10.0.1.50
    User ec2-user
    ProxyJump bastion
    LocalForward 8080 localhost:80
    IdentityFile ~/.ssh/aws-key.pem
```

**Comando simplificado final:**

```bash
ssh private-web
# Automáticamente salta por bastion Y crea el port forward
# Acceder a http://localhost:8080
```

**Recursos AWS necesarios:**

- 2 EC2 t2.micro
- VPC con 2 subnets (pública y privada)
- Security Groups configurados
- Nginx o crazy-bat corriendo en servidor privado
- 1 IP elástica (solo para bastion)

**Por qué sorprenderá:**

Muestra cómo combinar dos técnicas poderosas en un flujo práctico y real. Es exactamente lo que se necesita en entornos cloud modernos.

---

#### CASO 3 NUEVO: "La Ventana Mágica" - X11 Forwarding con Monitor CPU

**Clasificación:** ⭐⭐⭐ IMPACTO MUY ALTO  
**Tiempo estimado:** 10 minutos  
**Dificultad técnica:** Media  
**Factor WOW:** Muy Alto

**Concepto:**

Ejecutar una aplicación gráfica en AWS pero verla en tu pantalla local. Demostrar en tiempo real cómo la CPU del servidor remoto se dispara mientras lo vemos en nuestra ventana local.

**Arquitectura POC:**

- EC2 con servidor X11 instalado (Amazon Linux 2 + xorg)
- Tu equipo local con X11 (Linux nativo o WSL2 con VcXsrv en Windows)
- SSH con X11 forwarding habilitado

**Demostración paso a paso:**

1. **Conectar con X11 forwarding:**

   ```bash
   ssh -X ec2-user@ec2-instance
   ```

2. **Lanzar programa gráfico simple primero (validar que funciona):**

   ```bash
   xeyes &  # Los ojos siguen el cursor - prueba rápida
   # O si está disponible:
   xclock &
   ```

3. **Lanzar monitor de recursos:**

   ```bash
   # Opción 1: htop (si está instalado)
   htop

   # Opción 2: top en xterm
   xterm -e top &

   # Opción 3: Monitor gráfico (si GNOME está instalado)
   gnome-system-monitor &
   ```

4. **PRUEBA EMPÍRICA - Stress test:**

   ```bash
   # Instalar stress-ng si no está
   sudo yum install stress-ng -y

   # Ejecutar stress en 4 cores por 30 segundos
   stress-ng --cpu 4 --timeout 30s
   ```

**Efecto visual:**

La audiencia verá en TU pantalla local cómo la CPU del servidor AWS salta de 5% a 100% en tiempo real.

**Alternativa simplificada (si X11 da problemas):**

```bash
# Solo usar xeyes o xclock como demo
ssh -X ec2-user@ec2
xeyes &
# Mover el mouse - los ojos siguen. Simple pero efectivo.
```

**Configuración previa en EC2:**

```bash
# Instalar X11 básico
sudo yum install -y xorg-x11-apps xorg-x11-xauth

# Para htop
sudo yum install -y htop

# Para stress
sudo yum install -y stress-ng
```

**Configuración SSH servidor (`/etc/ssh/sshd_config`):**

```config
X11Forwarding yes
X11UseLocalhost yes
```

**Recursos AWS necesarios:**

- 1 EC2 t2.small (necesita algo más de recursos para X11)
- Security Group: solo puerto 22
- X11 instalado y configurado

**Por qué sorprenderá:**

- Visual e intuitivo
- Muestra capacidad poco conocida de SSH
- Útil para debugging remoto, aplicaciones gráficas, etc.
- El stress test es muy impactante visualmente

**Casos de uso reales:**

- Ejecutar IDE remoto (VSCode server, Eclipse)
- Debugging de aplicaciones gráficas
- Administración de servidores con herramientas GUI
- Acceso a aplicaciones legacy que solo tienen interfaz gráfica

---

#### CASO 3: "La Cárcel SSH" - Usuario Enjaulado + SFTP Only

**Clasificación:** ⭐⭐ IMPACTO MEDIO-ALTO  
**Tiempo estimado:** 8-10 minutos  
**Dificultad técnica:** Media  
**Factor WOW:** Medio

**Concepto:**

Crear un usuario que solo puede subir/bajar archivos vía SFTP, sin acceso a shell, confinado a un directorio específico (chroot).

**Casos de uso reales:**

- Cliente externo que sube backups
- Desarrollador que solo debe acceder a ciertos logs
- Partner que comparte archivos sin acceso al sistema

**Arquitectura POC:**

- EC2 con usuario enjaulado configurado
- Demostrar acceso SFTP exitoso
- Demostrar que SSH falla (no hay shell)
- Intentar escapar de la cárcel (demostrar que es seguro)

**Configuración SSH (`/etc/ssh/sshd_config`):**

```config
Match User jailuser
    ChrootDirectory /home/jailed/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
```

**Demostración en vivo:**

```bash
# Intento de SSH (falla)
ssh jailuser@ec2-server
# Resultado: "This service allows sftp connections only."

# SFTP funciona
sftp jailuser@ec2-server
> put test-file.txt
> ls
> get test-file.txt
> exit

# Verificación del chroot
# El usuario solo ve su directorio, no puede acceder a /etc, /home de otros, etc.
```

**Recursos AWS necesarios:**

- 1 EC2 t2.micro
- Security Group: puerto 22 (SSH/SFTP)

**Por qué sorprenderá:**

Seguridad práctica sin complicaciones. Alternativa simple a FTP/FTPS o soluciones de terceros.

---

#### CASO 4: "El Túnel del Tiempo" - SSH + Port Forwarding para Servicios

**Clasificación:** ⭐⭐ IMPACTO MEDIO  
**Tiempo estimado:** 8-10 minutos  
**Dificultad técnica:** Baja-Media  
**Factor WOW:** Medio

**Concepto:**

Acceder a servicios remotos (base de datos, panel web interno, VNC) a través de túnel SSH sin exponer puertos peligrosos a internet.

**Variantes a demostrar:**

**Opción A: Base de datos remota:**

```bash
# MySQL/PostgreSQL remoto accesible en localhost
ssh -L 3306:localhost:3306 user@db-server

# Ahora conectar con cliente local
mysql -h 127.0.0.1 -P 3306 -u dbuser -p
```

**Opción B: Panel web interno:**

```bash
# Servicio web en puerto 8080 del servidor
ssh -L 9000:localhost:8080 user@remote-server

# Acceder en navegador local
http://localhost:9000
```

**Opción C: VNC/Escritorio remoto:**

```bash
ssh -L 5900:localhost:5900 user@remote-server
# Conectar con cliente VNC a localhost:5900
```

**Recursos AWS necesarios:**

- 1 EC2 con servicio instalado (nginx, MySQL, VNC)
- Security Group: solo puerto 22 (SSH)

**Por qué sorprenderá:**

Demuestra cómo SSH puede reemplazar VPNs para muchos casos de uso. Seguridad sin complejidad.

---

### 🚀 CASOS BONUS (Si hay tiempo o para el repositorio)

#### CASO 5: "La Máquina del Tiempo SSH" - Conexión a Sistemas Legacy

**Clasificación:** ⭐ IMPACTO BAJO-MEDIO  
**Tiempo estimado:** 5-7 minutos  
**Basado en:** `error_en_la_conexión_SSH.md`

**Concepto:**

Conectar a sistemas antiguos (CentOS 6, Debian 7) con algoritmos SSH deprecados que los clientes modernos rechazan.

**POC:**

- EC2 con OpenSSH antiguo (o configurado para solo aceptar algoritmos legacy)
- Demostrar error de conexión desde cliente moderno
- Aplicar configuración de algoritmos permitidos
- Conexión exitosa

**Configuración cliente (`~/.ssh/config`):**

```config
Host legacy-server
    HostName old-server.example.com
    KexAlgorithms +diffie-hellman-group1-sha1
    Ciphers +aes128-cbc,3des-cbc
    HostKeyAlgorithms +ssh-rsa
```

---

#### CASO 6: "SOCKS Ninja" - Dynamic Port Forwarding como Proxy

**Clasificación:** ⭐⭐ IMPACTO MEDIO  
**Tiempo estimado:** 5-7 minutos

**Concepto:**

Navegar por internet "desde" otro servidor usando SSH como SOCKS proxy.

**POC:**

```bash
# Crear túnel SOCKS en puerto local 1080
ssh -D 1080 user@ec2-server

# Configurar navegador con SOCKS5 proxy: localhost:1080
# Visitar whatismyip.com → muestra IP del servidor AWS
```

**Usos prácticos:**

- Acceder a recursos desde otra ubicación geográfica
- Navegar de forma segura en WiFi público
- Testing de aplicaciones geo-restringidas

---

## 📋 SELECCIÓN FINAL para la Ponencia (40 min)

### Estructura definitiva

**Total: 40 minutos:**

1. **Presentación** (2 min)
   - Breve introducción
   - Overview de lo que se demostrará

2. **CASO 1: Túnel Inverso con Crazy-Bat + Systemd** (12 min)
   - ⭐⭐⭐ MUY IMPACTANTE
   - Túnel SSH inverso con systemd (básico)
   - Mención de autossh para producción
   - Demo visual con crazy-bat

3. **CASO 2: ProxyJump + Port Forwarding Integrados** (12 min)
   - ⭐⭐⭐ MUY ÚTIL Y COMPLETO
   - Saltar por bastiones Y acceder a servicio privado
   - Un flujo unificado que combina ambas técnicas
   - Aplicable a cualquier entorno cloud

4. **CASO 3: X11 Forwarding - Monitor CPU Remoto** (10 min)
   - ⭐⭐⭐ VISUAL E IMPACTANTE
   - Ventana gráfica local ejecutando programa remoto
   - Demo de stress CPU en vivo
   - Ver en tiempo real el uso de CPU de AWS

5. **Cierre + Casos Adicionales** (3 min)
   - Mención rápida: usuarios enjaulados, algoritmos legacy, SOCKS proxy
   - Referencia al repositorio con toda la documentación

6. **Q&A** (1 min)
   - Preguntas rápidas finales

### Ventajas de esta selección

✅ Usa crazy-bat (requisito prioritario)  
✅ Combina múltiples técnicas SSH en flujos prácticos y reales  
✅ Tres casos altamente visuales e impactantes  
✅ Casos independientes (si uno falla técnicamente, puedes continuar)  
✅ Automatizable con Terraform (Infraestructura como código)  
✅ Reserva tiempo para interrupciones y Q&A de la audiencia  
✅ Mayor profundidad: 12 min por caso vs 8-10 min permite manejar imprevistos  
✅ Casos aplicables al trabajo diario, no trucos exóticos  

### Casos mencionados en el cierre (no demostrados en vivo)

Estos casos se mencionarán brevemente en los últimos 3 minutos, indicando que están documentados en el repositorio:

- **Usuarios SSH enjaulados (chroot + SFTP only):** Seguridad práctica sin shell
  - Referencia: `README_jailed_user_tunnel.md`
  
- **Algoritmos SSH legacy:** Conectar a sistemas antiguos
  - Referencia: `README_ssh_legacy_algorithms.md`
  
- **SOCKS Proxy dinámico:** Navegar "desde" otro servidor
  - Comando rápido: `ssh -D 1080 user@server`

- **Otras posibilidades:** SCP, SFTP, rsync sobre SSH, configuraciones avanzadas del cliente

**Justificación de casos descartados:**

- **Usuario enjaulado:** Aunque útil, es más mérito de configuración chroot que de SSH puro
- **Algoritmos legacy:** Útil pero poco espectacular para demo en vivo
- **Multi-hop sin servicios:** Ya cubierto mejor en Caso 2 integrado

---

## 🛠️ Próximos Pasos

### Tarea 2: Selección definitiva de casos ✅ COMPLETADA

**Casos seleccionados:**

1. ✅ Túnel Inverso con Crazy-Bat + Systemd (12 min)
2. ✅ ProxyJump + Port Forwarding Integrados (12 min)
3. ✅ X11 Forwarding - Monitor CPU Remoto (10 min)

**Distribución de tiempo validada:** 40 min con margen para imprevistos y Q&A

### Tarea 3: Análisis de necesidades técnicas (SIGUIENTE)

Para cada caso seleccionado, definir:

#### CASO 1: Túnel Inverso + Crazy-Bat

- **Recursos AWS:**
  - 1x EC2 t2.micro (Amazon Linux 2)
  - 1x Security Group (SSH: 22, HTTP: 8080)
  - 1x IP Elástica
  
- **Configuración local:**
  - Docker con imagen crazy-bat
  - Servicio systemd configurado
  - Clave SSH para EC2
  
- **Scripts Terraform:** VPC, subnet pública, EC2, security group
- **User data EC2:** Configurar `GatewayPorts yes` en sshd
- **Plan B:** Grabación asciinema del flujo completo

#### CASO 2: ProxyJump + Port Forwarding

- **Recursos AWS:**
  - 2x EC2 t2.micro
  - 1x VPC con 2 subnets (pública + privada)
  - 2x Security Groups
  - 1x IP Elástica (bastion)
  
- **Servicios:**
  - Nginx o crazy-bat en servidor privado
  
- **Scripts Terraform:** VPC, subnets, route tables, EC2s, security groups
- **Archivo ~/.ssh/config:** Configuración de ProxyJump + LocalForward
- **Plan B:** Grabación asciinema + screenshots

#### CASO 3: X11 Forwarding + CPU Monitor

- **Recursos AWS:**
  - 1x EC2 t2.small (necesita más recursos para X11)
  - 1x Security Group (SSH: 22)
  - 1x IP Elástica
  
- **Configuración EC2:**
  - X11 instalado (xorg-x11-apps, xorg-x11-xauth)
  - htop, stress-ng instalados
  - `X11Forwarding yes` en sshd_config
  
- **Configuración local:**
  - X11 server (Linux nativo, WSL2 + VcXsrv, o XQuartz en Mac)
  - SSH client con soporte X11
  
- **Scripts Terraform:** EC2 con user data para instalar paquetes X11
- **Plan B:** Video pregrabado del xeyes + stress test

#### GitHub Actions Workflow

- **Trigger:** Manual (workflow_dispatch)
- **Acciones:**
  - `terraform init`
  - `terraform plan`
  - `terraform apply -auto-approve`
  - Output de IPs públicas y comandos SSH
  
- **Destroy:** Workflow separado para limpiar recursos

#### Código y Documentación

- Scripts de demo en `scripts/`
- Grabaciones asciinema en `demos/`
- README por cada caso con comandos exactos
- Troubleshooting común

---

## 📝 Notas Adicionales

### Consideraciones de tiempo

- Cada caso tiene margen de 8-10 min (incluye setup si algo falla)
- Priorizar casos 1-3, caso 4 es opcional
- Tener asciinema pregrabado como plan B

### Riesgos y mitigaciones

**Riesgo:** Fallo de red durante demo  
**Mitigación:** Grabaciones asciinema + slides con capturas

**Riesgo:** Terraform tarda más de lo esperado  
**Mitigación:** Pre-desplegar infraestructura 1 hora antes, solo hacer `terraform apply` si es necesario recrear

**Riesgo:** Audiencia se pierde con comandos complejos  
**Mitigación:** Tener comandos en slides + explicar antes de ejecutar

### Material para compartir al final

- Este repositorio ssh-tips completo
- Enlaces a documentación oficial
- Grabaciones asciinema de cada caso
- Código Terraform usado
- Configuraciones SSH de ejemplo

---

**Fecha de creación:** 6 de diciembre de 2025  
**Estado:** Propuesta inicial - Pendiente de validación  
**Próxima tarea:** Selección definitiva de casos (Tarea 2)
