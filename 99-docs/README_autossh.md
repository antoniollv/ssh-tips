# AutoSSH Configuration

Installation of autossh package for CentOS 6 64bit

## Installation from CentOS Extras Repository

The CentOS Extras repository includes a package to install EPEL, and is enabled by default. To install the EPEL package, run the following command:

```bash
sudo yum install epel-release
sudo yum install autossh
```

## Tunnel User Configuration

Add the user that will create the tunnel:

```bash
adduser <USERNAME>
passwd <USERNAME>
```

### Allow User Access to sudo on CentOS 6

Add the user to the wheel group:

```bash
usermod -a -G wheel <USERNAME>
```

Check if the user has been added to the group:

```bash
id <USERNAME>
```

With `visudo` in `/etc/sudoers` change the configuration if necessary.

### SSH Key Generation for the Tunnel User

```bash
su - <USERNAME>
ssh-keygen -t rsa # Leave passphrase blank
```

## Key Exchange Between Server and Client

Add the content of `.ssh/id_rsa.pub` to the `.ssh/authorized_keys` file

Copy the example file from `autossh.host` to `/etc/init.d/autossh`:

```bash
cp /usr/share/doc/autossh/examples/autossh.host /etc/init.d/autossh
```

## Edit the autossh File

At this point it is better to copy the `tunelssl` file which is already configured to run as a daemon.

Change the ports to the desired ones.

Grant execution permissions and configure startup execution:

```bash
chmod +x tunelssl
chkconfig tunelssl on
```
