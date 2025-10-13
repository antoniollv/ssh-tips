mkdir -p /home/JailUsers/dev
mkdir -p /home/JailUsers/bin
mkdir -p /home/JailUsers/etc
mkdir -p /home/JailUsers/lib64
chmod 755 /home/JailUsers/
  
mknod -m 666 /home/JailUsers/dev/null c 1 3
mknod -m 666 /home/JailUsers/dev/tty c 5 0
mknod -m 666 /home/JailUsers/dev/zero c 1 5
mknod -m 666 /home/JailUsers/dev/random c 1 8

ldd /bin/bash

cp -v /bin/bash /home/JailUsers/bin
cp /lib64/libtinfo.so.5 /home/JailUsers/lib64
cp /lib64/ld-linux-x86-64.so.2 ./
cp /lib64/libdl.so.2 /home/JailUsers/lib64
cp /lib64/libc.so.6 /home/JailUsers/lib64

groupadd -g 1100 jailusers

# Editar /etc/ssh/sshd_config
# Se añaden al final las siguientes líneas
#
# Match Group jailusers
# ChrootDirectory /home/JailUsers/

systemctl restart sshd

useradd -d /home/JailUsers/home/demogexflow -m -g jailusers demogexflow

cp -vf /etc/{passwd,group} /home/JailUsers/etc/
mkdir -p /home/JailUsers/home/demogexflow/.ssh/
cp demogexflow.pem.pub /home/JailUsers/home/demogexflow/.ssh/authorized_keys
chown demogexflow:jailusers -R /home/JailUsers/home/demogexflow/.ssh
chmod 700 /home/JailUsers/home/demogexflow/.ssh
chmod 400 /home/JailUsers/home/demogexflow/.ssh/authorized_keys

# Incluir ls como comando, no es necesario
ldd /bin/ls
cp -v /bin/ls /home/JailUsers/bin/

cp /lib64/libselinux.so.1 /home/JailUsers/lib64/
cp /lib64/libcap.so.2 /home/JailUsers/lib64/
cp /lib64/libacl.so.1 /home/JailUsers/lib64/
cp /lib64/libc.so.6 /home/JailUsers/lib64/
cp lib64/libpcre.so.1 /home/JailUsers/lib64/
cp /lib64/libpcre.so.1 /home/JailUsers/lib64/
cp /lib64/libdl.so.2 /home/JailUsers/lib64/
cp /lib64/ld-linux-x86-64.so.2 /home/JailUsers/lib64/
cp /lib64/libattr.so.1 /home/JailUsers/lib64/
cp /lib64/libpthread.so.0 /home/JailUsers/lib64/

# SSH
# Para permitir forward de puerto en todos los interface distintos a localhost 
# Editar /etc/ssh/sshd_config
# GatewayPorts yes
#
# Para mantener las sesiones
# ClientAliveInterval 60
# ClientAliveCountMax 3

Unidad  systemd para túnel ssh

[Unit]
Description=Keeps a tunnel to 'ssh.teralco.com' open
After=network.target ssh.service
# On Ubuntu
#After=network-online.target ssh.service

[Service]
Environment="AUTOSSH_PORT=27701"
Environment="PORT_MIDDLEMAN_WILL_LISTEN_ON=11949"
Environment="MIDDLEMAN_SERVER_AND_USERNAME=demogexflow@ssh.teralco.com"
Environment="AUTOSSH_GATETIME=0"
Environment="PUERTO_SSH=22"
Environment="MIDDLEMAN_PUERTO_SSH=2222"
User=teralco
#ExecStart=/usr/bin/autossh -N -R -f ${AUTOSSH_PORT}:${PORT_MIDDLEMAN_WILL_LISTEN_ON}:localhost:${PUERTO_SSH} -p ${MIDDLEMAN_PUERTO_SSH} ${MIDDLEMAN_SERVER_AND_USERNAME}
ExecStart=/usr/bin/autossh -N -R ${AUTOSSH_PORT}:${PORT_MIDDLEMAN_WILL_LISTEN_ON}:localhost:${PUERTO_SSH} -p ${MIDDLEMAN_PUERTO_SSH} ${MIDDLEMAN_SERVER_AND_USERNAME}

# Restart every >2 seconds to avoid StartLimitInterval failure
#RestartSec=5
#Restart=always

[Install]
WantedBy=multi-user.target


ssh-keyscan -t rsa 192.168.101.241 >>$HOME/.ssh/known_hosts