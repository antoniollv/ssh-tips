# Error de Conexión SSH con Algoritmos Legacy

Error en la conexión SSH en los nuevos sistemas operativos: `Failed to startup SSH session: kex error`

## Descripción del problema

Ver referencia en: <http://lists.x2go.org/pipermail/x2go-user/2014-October/002523.html>

Por temas de seguridad se han deshabilitado algunos protocolos que se sabe que no son muy seguros para el acceso por SSH, en las nuevas implementaciones de Linux. Este es el caso de Debian 8 y versiones posteriores.

Al tratar de conectarse con estos algoritmos, por ejemplo con Remmina, se tiene un error como el que sigue:

```text
Failed to startup SSH session: kex error : did not find one of algos diffie-hellman-group1-sha1 in list curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1 for kex algos
```

Esto significa que algunos algoritmos están deshabilitados y por lo tanto el servidor no va a aceptar conexiones con ellos.

## Solución

Si el software que usamos no soporta otros algoritmos podemos habilitar los algoritmos legacy, pero teniendo en cuenta que son menos seguros.

Para ello editamos `/etc/ssh/sshd_config` y le agregamos al final lo siguiente:

```config
# Algoritmos kex
KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
```

Reiniciamos el servicio SSH:

```bash
sudo systemctl restart sshd
```

## Advertencia de seguridad

⚠️ **Importante:** Esta configuración habilita algoritmos deprecados que tienen vulnerabilidades conocidas. Solo úsala si es absolutamente necesario para conectarte a sistemas legacy que no pueden actualizarse.
