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

#### CASO 1: "El Servidor que No Existe" - Túnel Inverso con Crazy-Bat

**Clasificación:** ⭐⭐⭐ IMPACTO ALTO  
**Tiempo estimado:** 8-10 minutos  
**Dificultad técnica:** Media  
**Factor WOW:** Muy Alto

**Concepto:**

Demostrar un servidor web accesible desde internet que físicamente está en tu laptop, sin IP pública, usando túnel SSH inverso y crazy-bat.

**Arquitectura POC:**

- EC2 en AWS con IP pública (servidor bastion)
- Tu laptop local ejecuta crazy-bat (servidor netcat en puerto 8080)
- Túnel SSH inverso: laptop → EC2 (remote port forwarding)
- La audiencia accede a `http://ec2-public-ip:8080` y ve la página de crazy-bat
- **Momento sorpresa:** Matas el servicio en tu laptop y la web se cae → demuestras que estaba en local

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

**Opción A: Base de datos remota**

```bash
# MySQL/PostgreSQL remoto accesible en localhost
ssh -L 3306:localhost:3306 user@db-server

# Ahora conectar con cliente local
mysql -h 127.0.0.1 -P 3306 -u dbuser -p
```

**Opción B: Panel web interno**

```bash
# Servicio web en puerto 8080 del servidor
ssh -L 9000:localhost:8080 user@remote-server

# Acceder en navegador local
http://localhost:9000
```

**Opción C: VNC/Escritorio remoto**

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

## 📋 Recomendación Final para la Ponencia (40 min)

### Estructura propuesta

**Total: 40 minutos**

1. **Presentación** (2 min)
   - Breve introducción
   - Overview de lo que se demostrará

2. **CASO 1: Túnel Inverso con Crazy-Bat** (10 min)
   - ⭐⭐⭐ MUY IMPACTANTE
   - Usa crazy-bat (requisito)
   - Visual y fácil de entender

3. **CASO 2: ProxyJump Multi-Hop** (10 min)
   - ⭐⭐⭐ MUY ÚTIL
   - Demuestra poder de SSH en topologías complejas
   - Aplicable a cualquier entorno cloud

4. **CASO 3: Usuario Enjaulado (SFTP Only)** (10 min)
   - ⭐⭐ SEGURIDAD PRÁCTICA
   - Caso de uso real y común
   - Fácil de implementar

5. **CASO BONUS: SOCKS Proxy** (5 min)
   - Solo si hay tiempo
   - Demo rápida y visual
   - Útil para audiencia técnica

6. **Despedida + Q&A** (3 min)
   - Resumen del repositorio compartido
   - Preguntas rápidas

### Ventajas de esta selección

✅ **Usa crazy-bat** (tu requisito prioritario)  
✅ **Cubre tunneling completo:** local forwarding, remote forwarding, dynamic forwarding  
✅ **Muestra seguridad práctica:** usuarios enjaulados, acceso sin exponer puertos  
✅ **Cada caso es independiente:** Si uno falla técnicamente, puedes continuar  
✅ **Automatizable con Terraform:** Infraestructura como código  
✅ **Visual e impactante:** No solo teoría, POCs reales  
✅ **Aplicable al trabajo diario:** No son trucos exóticos, son herramientas útiles

### Casos descartados (pero disponibles en repositorio)

- **Algoritmos deprecados:** Útil pero poco espectacular para demo en vivo
- **X2GO/VNC:** Más complejo de configurar, menos impactante que otros casos
- **Autossh persistente:** Puede integrarse en CASO 1 como variante

---

## 🛠️ Próximos Pasos (Tarea 2 y 3)

### Tarea 2: Selección definitiva de casos

- Validar que los 3-4 casos propuestos son los adecuados
- Ajustar según tu preferencia
- Definir orden de presentación

### Tarea 3: Análisis de necesidades técnicas

Para cada caso seleccionado, definir:

- **Recursos AWS exactos:** Tipos de instancia, VPC, subnets, security groups
- **Scripts de configuración:** User data, configuración SSH, servicios
- **Código Terraform:** IaC para despliegue automático
- **GitHub Actions:** Workflow para deploy/destroy bajo demanda
- **Plan B:** Grabaciones asciinema como respaldo si falla algo en vivo
- **Comandos de demo:** Script exacto de lo que ejecutarás en vivo

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
