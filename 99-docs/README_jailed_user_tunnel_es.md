# Usuario Enjaulado con SSH y Túnel

Este documento describe cómo crear un usuario SSH enjaulado (chroot) con capacidades limitadas y configurar túneles SSH persistentes.

## Crear estructura de directorios y dispositivos

```bash
mkdir -p /home/JailUsers/dev
mkdir -p /home/JailUsers/bin
mkdir -p /home/JailUsers/etc
mkdir -p /home/JailUsers/lib64
chmod 755 /home/JailUsers/

mknod -m 666 /home/JailUsers/dev/null c 1 3
mknod -m 666 /home/JailUsers/dev/tty c 5 0
mknod -m 666 /home/JailUsers/dev/zero c 1 5
mknod -m 666 /home/JailUsers/dev/random c 1 8
```

## Copiar Bash y librerías necesarias

```bash
ldd /bin/bash

cp -v /bin/bash /home/JailUsers/bin
cp /lib64/libtinfo.so.5 /home/JailUsers/lib64
cp /lib64/ld-linux-x86-64.so.2 /home/JailUsers/lib64/
cp /lib64/libdl.so.2 /home/JailUsers/lib64
cp /lib64/libc.so.6 /home/JailUsers/lib64
```

## Crear grupo y usuario enjaulado

```bash
groupadd -g 1100 jailusers
```

### Editar `/etc/ssh/sshd_config`

Agrega al final las siguientes líneas:

```config
Match Group jailusers
ChrootDirectory /home/JailUsers/
```

Reinicia el servicio SSH:

```bash
systemctl restart sshd
```

Crea el usuario enjaulado:

```bash
useradd -d /home/JailUsers/home/demogexflow -m -g jailusers demogexflow
```

## Preparar archivos y llaves

```bash
cp -vf /etc/{passwd,group} /home/JailUsers/etc/
mkdir -p /home/JailUsers/home/demogexflow/.ssh/
cp demogexflow.pem.pub /home/JailUsers/home/demogexflow/.ssh/authorized_keys
chown demogexflow:jailusers -R /home/JailUsers/home/demogexflow/.ssh
chmod 700 /home/JailUsers/home/demogexflow/.ssh
chmod 400 /home/JailUsers/home/demogexflow/.ssh/authorized_keys
```

## Incluir comando `ls` (opcional)

```bash
ldd /bin/ls
cp -v /bin/ls /home/JailUsers/bin/

cp /lib64/libselinux.so.1 /home/JailUsers/lib64/
cp /lib64/libcap.so.2 /home/JailUsers/lib64/
cp /lib64/libacl.so.1 /home/JailUsers/lib64/
cp /lib64/libc.so.6 /home/JailUsers/lib64/
cp /lib64/libpcre.so.1 /home/JailUsers/lib64/
cp /lib64/libdl.so.2 /home/JailUsers/lib64/
cp /lib64/ld-linux-x86-64.so.2 /home/JailUsers/lib64/
cp /lib64/libattr.so.1 /home/JailUsers/lib64/
cp /lib64/libpthread.so.0 /home/JailUsers/lib64/
```

## Configuración de SSH

### Permitir forward de puerto en todas las interfaces

Para permitir forward de puerto en todas las interfaces (no solo localhost), editar `/etc/ssh/sshd_config` y agregar:

```config
GatewayPorts yes
```

### Mantener las sesiones activas

```config
ClientAliveInterval 60
ClientAliveCountMax 3
```

## Unidad systemd para túnel SSH

Crea un archivo de unidad en `/etc/systemd/system/autossh-tunnel.service`:

```ini
[Unit]
Description=Keeps a tunnel to 'ssh.teralco.com' open
After=network.target ssh.service
# En Ubuntu: After=network-online.target ssh.service

[Service]
Environment="AUTOSSH_PORT=27701"
Environment="PORT_MIDDLEMAN_WILL_LISTEN_ON=11949"
Environment="MIDDLEMAN_SERVER_AND_USERNAME=demogexflow@ssh.teralco.com"
Environment="AUTOSSH_GATETIME=0"
Environment="PUERTO_SSH=22"
Environment="MIDDLEMAN_PUERTO_SSH=2222"
User=teralco
ExecStart=/usr/bin/autossh -N -R ${AUTOSSH_PORT}:${PORT_MIDDLEMAN_WILL_LISTEN_ON}:localhost:${PUERTO_SSH} -p ${MIDDLEMAN_PUERTO_SSH} ${MIDDLEMAN_SERVER_AND_USERNAME}

# Reiniciar cada >2 segundos para evitar fallo de StartLimitInterval
#RestartSec=5
#Restart=always

[Install]
WantedBy=multi-user.target
```

## Añadir clave SSH al archivo de hosts conocidos

```bash
ssh-keyscan -t rsa <IP> >>$HOME/.ssh/known_hosts
```
