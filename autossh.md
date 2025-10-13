# CONFIGURACIÓN AUTOSSH

Optencion del paquete autossh para Centos 6 64bit

CentOS Extras repository

The CentOS Extras repository includes a package to install EPEL, and is enabled by default. To install the EPEL package, run the following command:

```bash
sudo yum install epel-release
sudo yum install autossh
```

Añadimos el usuario que cerrara el tunel

```bash
adduser <USUARIO>
passwd <USUARIO>
```

Permitir a un usuario el acceso a sudo en CentOS 6

Añadir el usuario al grupo wheel

`usermod -a -G wheel <USUARIO>`

Comprobar si el usuario ha sido incluido al grupo

`id <USUARIO>`

Con `visudo` en `/etc/sudoers` cambiamos la configuración si fuera necesario

Generación de la clave SSH para el suario que cerrara el tunel

```bash
su - <USUARIO>
ssh-keygen -t rsa //Dejar en blanco passphrase
```

## Intercambio de claves entre el servidor y el cliente.

Añadir al fichero `.ssh/authorized_keys` el contenido de `.ssh/id_rsa.pub`

Copiar el fichero de ejmemplo de `autossh.host` a `/etc/init.d/autossh`

`cp /usr/share/doc/autossh/examples/autossh.host /etc/init.d/autossh`

## Editar el fichero autossh.

En este punto es mejor copiar el fichero tunelssl que ya esta configurado para correr como demonio

Cambiamos los puertos por los deseados.

Le damos permiso de ejecucion y configuramos ejecución al inicio 

```bash
chmod +x tunelssl
chkconfig tunelssl on
```


