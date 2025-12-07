# Configuración AutoSSH

Obtención del paquete autossh para CentOS 6 64bit

## Instalación desde repositorio CentOS Extras

El repositorio CentOS Extras incluye un paquete para instalar EPEL, y está habilitado por defecto. Para instalar el paquete EPEL, ejecuta el siguiente comando:

```bash
sudo yum install epel-release
sudo yum install autossh
```

## Configuración del usuario para el túnel

Añadimos el usuario que creará el túnel:

```bash
adduser <USUARIO>
passwd <USUARIO>
```

### Permitir a un usuario el acceso a sudo en CentOS 6

Añadir el usuario al grupo wheel:

```bash
usermod -a -G wheel <USUARIO>
```

Comprobar si el usuario ha sido incluido al grupo:

```bash
id <USUARIO>
```

Con `visudo` en `/etc/sudoers` cambiamos la configuración si fuera necesario.

### Generación de la clave SSH para el usuario que creará el túnel

```bash
su - <USUARIO>
ssh-keygen -t rsa # Dejar en blanco passphrase
```

## Intercambio de claves entre el servidor y el cliente

Añadir al fichero `.ssh/authorized_keys` el contenido de `.ssh/id_rsa.pub`

Copiar el fichero de ejemplo de `autossh.host` a `/etc/init.d/autossh`:

```bash
cp /usr/share/doc/autossh/examples/autossh.host /etc/init.d/autossh
```

## Editar el fichero autossh

En este punto es mejor copiar el fichero `tunelssl` que ya está configurado para correr como demonio.

Cambiamos los puertos por los deseados.

Le damos permiso de ejecución y configuramos ejecución al inicio:

```bash
chmod +x tunelssl
chkconfig tunelssl on
```
