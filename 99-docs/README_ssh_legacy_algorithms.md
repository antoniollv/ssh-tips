# SSH Connection Error with Legacy Algorithms

SSH connection error on new operating systems: `Failed to startup SSH session: kex error`

## Problem Description

See reference at: <http://lists.x2go.org/pipermail/x2go-user/2014-October/002523.html>

For security reasons, some protocols known to be insecure for SSH access have been disabled in newer Linux implementations. This is the case with Debian 8 and later versions.

When trying to connect with these algorithms, for example with Remmina, you get an error like the following:

```text
Failed to startup SSH session: kex error : did not find one of algos diffie-hellman-group1-sha1 in list curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1 for kex algos
```

This means that some algorithms are disabled and therefore the server will not accept connections with them.

## Solution

If the software we use does not support other algorithms, we can enable legacy algorithms, but keeping in mind that they are less secure.

To do this, edit `/etc/ssh/sshd_config` and add the following at the end:

```config
# Kex algorithms
KexAlgorithms diffie-hellman-group-exchange-sha256,diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
```

Restart the SSH service:

```bash
sudo systemctl restart sshd
```

## Security Warning

⚠️ **Important:** This configuration enables deprecated algorithms with known vulnerabilities. Only use it if absolutely necessary to connect to legacy systems that cannot be updated.
