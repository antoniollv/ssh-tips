# Scripts de Demostración - Túnel SSH Inverso

Este directorio contiene scripts de automatización para la demostración del túnel SSH inverso.

## 📋 Descripción de Scripts

Todos los scripts muestran los comandos antes de ejecutarlos para fines demostrativos, usando salida codificada por colores:

- **🔵 Cabeceras azules**: Separadores de sección
- **🟡 Amarillo**: Comandos que se están ejecutando
- **🟢 Verde**: Mensajes de éxito e información
- **🟠 Naranja**: Advertencias
- **🔴 Rojo**: Errores

## 🚀 Inicio Rápido

### Opción A: Configuración Automatizada (Recomendada)

```bash
# 1. Iniciar servidor web crazy-bat
./setup-crazy-bat.sh

# 2. Iniciar el túnel inverso (reemplazar con tu IP de EC2)
./setup-tunnel.sh 54.123.45.67

# 3. En otra terminal, verificar que todo funciona
./verify-demo.sh 54.123.45.67

# 4. Al terminar, limpiar
./cleanup.sh
```

### Opción B: Servicio systemd (Como en Producción)

```bash
# 1. Iniciar crazy-bat
./setup-crazy-bat.sh

# 2. Instalar como servicio systemd (requiere sudo)
sudo ./install-systemd-service.sh 54.123.45.67

# 3. Verificar
./verify-demo.sh 54.123.45.67

# 4. Limpiar
./cleanup.sh
```

## 📝 Detalles de los Scripts

### `setup-crazy-bat.sh`

Prepara e inicia el servidor web crazy-bat.

**Uso:**

```bash
./setup-crazy-bat.sh [CRAZY_BAT_DIR] [PORT]
```

**Parámetros:**

- `CRAZY_BAT_DIR`: Ruta al repositorio crazy-bat (predeterminado: `$HOME/DevOps/crazy-bat`)
- `PORT`: Puerto en el que ejecutar el servidor (predeterminado: `8085`)

**Qué hace:**

1. Clona crazy-bat si no está presente
2. Verifica la instalación de Docker
3. Detiene cualquier contenedor existente
4. Construye la imagen Docker
5. Inicia el contenedor crazy-bat en el puerto especificado
6. Verifica que el servicio sea accesible en localhost

**Ejemplo:**

```bash
./setup-crazy-bat.sh ~/projects/crazy-bat 8085
```

### `setup-tunnel.sh`

Establece el túnel SSH inverso manualmente (proceso en primer plano).

**Uso:**

```bash
./setup-tunnel.sh <EC2_PUBLIC_IP> [DEMO_PORT] [SSH_KEY] [LOCAL_SERVICE_PORT]
```

**Parámetros:**

- `EC2_PUBLIC_IP`: IP pública de tu instancia EC2 (requerido)
- `DEMO_PORT`: Puerto en EC2 a exponer (predeterminado: `8080`)
- `SSH_KEY`: Ruta a la clave privada SSH (predeterminado: `~/.ssh/id_rsa`)
- `LOCAL_SERVICE_PORT`: Puerto local donde se ejecuta crazy-bat (predeterminado: `8085`)

**Qué hace:**

1. Verifica permisos de la clave SSH
2. Prueba conectividad SSH a EC2
3. Verifica que el servicio local esté ejecutándose
4. Verifica la configuración SSHD de EC2
5. Establece el túnel inverso

**Ejemplo:**

```bash
./setup-tunnel.sh 54.123.45.67 8080 ~/.ssh/ssh-tips-key.pem 8085
```

**Nota:** Esto se ejecuta en primer plano. Presiona `Ctrl+C` para detener el túnel.

### `install-systemd-service.sh`

Instala el túnel inverso como un servicio systemd (requiere root).

**Uso:**

```bash
sudo ./install-systemd-service.sh <EC2_PUBLIC_IP> [DEMO_PORT] [LOCAL_PORT] [SSH_KEY]
```

**Parámetros:**

- `EC2_PUBLIC_IP`: IP pública de tu instancia EC2 (requerido)
- `DEMO_PORT`: Puerto en EC2 a exponer (predeterminado: `8080`)
- `LOCAL_PORT`: Puerto local donde se ejecuta crazy-bat (predeterminado: `8085`)
- `SSH_KEY`: Ruta a la clave privada SSH (predeterminado: `~/.ssh/id_rsa`)

**Qué hace:**

1. Crea el archivo de servicio systemd desde la plantilla
2. Configura reinicio automático en caso de fallo
3. Habilita el servicio para iniciar en el arranque
4. Inicia el servicio

**Ejemplo:**

```bash
sudo ./install-systemd-service.sh 54.123.45.67 8080 8085 ~/.ssh/ssh-tips-key.pem
```

**Comandos systemd:**

```bash
# Ver estado
sudo systemctl status reverse-tunnel

# Ver logs (seguimiento)
sudo journalctl -u reverse-tunnel -f

# Detener/iniciar/reiniciar
sudo systemctl stop reverse-tunnel
sudo systemctl start reverse-tunnel
sudo systemctl restart reverse-tunnel

# Deshabilitar (no iniciará en el arranque)
sudo systemctl disable reverse-tunnel
```

### `verify-demo.sh`

Verifica que todos los componentes de la demostración estén funcionando correctamente.

**Uso:**

```bash
./verify-demo.sh <EC2_PUBLIC_IP> [DEMO_PORT] [SSH_KEY]
```

**Parámetros:**

- `EC2_PUBLIC_IP`: IP pública de tu instancia EC2 (requerido)
- `DEMO_PORT`: Puerto a probar (predeterminado: `8080`)
- `SSH_KEY`: Ruta a la clave privada SSH (predeterminado: `~/.ssh/id_rsa`)

**Qué verifica:**

1. El servicio local (crazy-bat) está ejecutándose
2. La conexión SSH a EC2 funciona
3. El proceso del túnel SSH está activo
4. EC2 está escuchando en el puerto de demostración
5. La URL pública es accesible
6. El contenido coincide entre las URLs local y pública

**Ejemplo:**

```bash
./verify-demo.sh 54.123.45.67 8080 ~/.ssh/ssh-tips-key.pem
```

### `cleanup.sh`

Detiene y limpia todos los componentes de la demostración.

**Uso:**

```bash
./cleanup.sh [CRAZY_BAT_DIR]
```

**Parámetros:**

- `CRAZY_BAT_DIR`: Ruta al repositorio crazy-bat (predeterminado: `$HOME/DevOps/crazy-bat`)

**Qué hace:**

1. Detiene el servicio systemd (si está ejecutándose)
2. Mata los procesos del túnel SSH manual
3. Detiene el contenedor Docker de crazy-bat
4. Muestra los puertos que aún están escuchando

**Ejemplo:**

```bash
./cleanup.sh ~/projects/crazy-bat
```

## 🎬 Flujo de la Demostración

### Lista de Verificación Pre-Demostración

```bash
# 1. Hacer scripts ejecutables
chmod +x *.sh

# 2. Desplegar infraestructura AWS con GitHub Actions o:
cd terraform
terraform init -backend-config="bucket=TU_BUCKET" \
               -backend-config="key=ssh-tips/02-reverse-tunnel/terraform.tfstate" \
               -backend-config="region=eu-west-1"
terraform apply

# 3. Anotar la IP pública de EC2 de la salida de terraform
terraform output ec2_public_ip
```

### Durante la Demostración

```bash
# Mostrar inicio de crazy-bat
./setup-crazy-bat.sh

# Mostrar establecimiento del túnel
./setup-tunnel.sh <EC2_IP>

# En otra terminal, verificar
./verify-demo.sh <EC2_IP>

# Compartir la URL con la audiencia
# Mostrar detención/inicio de crazy-bat para demostrar el túnel
docker stop crazy-bat
docker start crazy-bat
```

### Post-Demostración

```bash
# Limpiar
./cleanup.sh

# Destruir infraestructura AWS
cd terraform
terraform destroy
```

## 🎨 Salida con Colores

Los scripts usan códigos de color ANSI para mejor visibilidad:

- **Cian/Amarillo**: Comandos que se están ejecutando
- **Verde**: Mensajes de éxito
- **Amarillo**: Advertencias
- **Rojo**: Errores
- **Azul**: Cabeceras de sección

Para deshabilitar colores, redirige a un archivo o modifica las variables de color en cada script.

## 🔧 Solución de Problemas

### "Permission denied" en scripts

```bash
chmod +x *.sh
```

### Error de permisos de clave SSH

```bash
chmod 600 ~/.ssh/tu-clave.pem
```

### Docker no encontrado

Instalar Docker:

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install docker.io

# O usar instalación oficial de Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Puerto 8080 ya en uso

```bash
# Encontrar qué está usando el puerto
sudo netstat -tlnp | grep :8080
# o
sudo ss -tlnp | grep :8080

# Matar el proceso o cambiar el puerto en los scripts
```

### El túnel se desconecta frecuentemente

Considera usar `autossh` en su lugar (ver `../99-docs/README_autossh_es.md`) o aumentar el `ServerAliveInterval` en los scripts.

## 📚 Recursos Adicionales

- [Documentación Principal de la Demostración](./README_es.md)
- [Infraestructura Terraform](./terraform/README_terraform_es.md)
- [Documentación autossh](../99-docs/README_autossh_es.md)
- [Proyecto crazy-bat](https://github.com/antoniollv/crazy-bat)
