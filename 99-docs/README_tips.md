# ssh-tips

SSH tips &amp; tricks

## Introduction

SSH (Secure Shell) is a cryptographic network protocol that provides a secure channel over an unsecured network. It's primarily used for secure remote login to computer systems, but it can also be used for secure file transfers, port forwarding, and tunneling various network services.

This document provides practical tips and tricks for everyday SSH usage, covering essential configuration and common use cases. It is not intended to be a comprehensive protocol specification, but rather a quick reference for common tasks.

## History

SSH was developed in 1995 by Tatu Ylönen in response to a password-sniffing attack at his university network. It was designed as a secure replacement for Telnet, rlogin, rsh, and rcp, which transmitted data in plaintext.

Key milestones:

- **SSH-1** (1995): Original protocol with security vulnerabilities
- **SSH-2** (2006): Current standard with improved security, became IETF standard (RFC 4251-4254)
- **OpenSSH** (1999): The most widely used implementation, developed by the OpenBSD project

## Server Configuration

### Basic SSH Server Setup

**Installation (Debian/Ubuntu):**

```bash
sudo apt update
sudo apt install openssh-server
```

**Installation (RedHat/CentOS):**

```bash
sudo yum install openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
```

### Essential Server Configuration Tips

The main configuration file is `/etc/ssh/sshd_config`. Here are key settings:

**Disable root login:**

```config
PermitRootLogin no
```

**Change default port (security through obscurity):**

```config
Port 2222
```

**Enable public key authentication:**

```config
PubkeyAuthentication yes
```

**Disable password authentication (after setting up keys):**

```config
PasswordAuthentication no
```

**Limit user access:**

```config
AllowUsers user1 user2
```

**After changes, restart SSH service:**

```bash
sudo systemctl restart sshd
```

## Client Configuration

### SSH Client Tips and Tricks

1. **SSH Config File (`~/.ssh/config`)**

   Create shortcuts for frequently accessed servers:

    ```config
    Host myserver
    HostName example.com
    User username
    Port 2222
    IdentityFile ~/.ssh/id_rsa_custom
    ```

   Now connect with just: `ssh myserver`

2. **Generate SSH Keys**

    ```bash
    # Generate RSA key (4096 bits recommended)
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

    # Generate Ed25519 key (modern, recommended)
    ssh-keygen -t ed25519 -C "your_email@example.com"
    ```

3. **Copy Public Key to Server**

    ```bash
    ssh-copy-id user@hostname
    # Or specify a key:
    ssh-copy-id -i ~/.ssh/id_rsa.pub user@hostname
    ```

4. **SSH Agent (avoid typing password repeatedly)**

    ```bash
    # Start agent
    eval "$(ssh-agent -s)"

    # Add key
    ssh-add ~/.ssh/id_rsa
    ```

5. **Port Forwarding**

    **Local port forwarding** (access remote service locally):

    ```bash
    ssh -L 8080:localhost:80 user@remote-server
    ```

    Now access remote server's port 80 via localhost:8080

    **Remote port forwarding** (expose local service to remote):

    ```bash
    ssh -R 9090:localhost:3000 user@remote-server
    ```

    **Dynamic port forwarding (SOCKS proxy):**

    ```bash
    ssh -D 1080 user@remote-server
    ```

6. **Keep Connection Alive**

    Add to `~/.ssh/config`:

    ```config
    Host *
        ServerAliveInterval 60
        ServerAliveCountMax 3
    ```

7. **Jump Hosts (ProxyJump)**

    Access a server through a bastion/jump host:

    ```bash config
    ssh -J jumphost targethost
    ```

    Or in config:

    ```config
    Host target
        HostName target.internal
        ProxyJump jumphost
    ```

8. **SCP and SFTP for File Transfer**

    ```bash
    # Copy file to remote
    scp local-file.txt user@remote:/path/to/destination/

    # Copy from remote
    scp user@remote:/path/to/file.txt ./local-directory/

    # Copy directory recursively
    scp -r local-directory user@remote:/path/

    # SFTP interactive session
    sftp user@remote
    ```

9. **SSH Tunneling for Databases**

    ```bash
    # Access remote MySQL/PostgreSQL locally
    ssh -L 3306:localhost:3306 user@dbserver
    ```

10. **Execute Remote Commands**

    ```bash
    # Run single command
    ssh user@server "ls -la /var/log"

    # Run multiple commands
    ssh user@server "cd /var/www && git pull && npm install"
    ```

## Current Usage

SSH is ubiquitous in modern IT infrastructure:

### DevOps & Cloud Computing

- Remote server administration
- Continuous Integration/Deployment pipelines
- Container orchestration (Kubernetes, Docker)
- Cloud instance management (AWS, Azure, GCP)

### Development Workflows

- Git repository access (GitHub, GitLab, Bitbucket)
- Remote development environments
- VS Code Remote-SSH extension
- Remote debugging

### Network Administration

- Secure file transfers (SFTP, SCP)
- Network device configuration (routers, switches)
- Port forwarding and tunneling
- VPN alternatives

### Security Best Practices

- Use SSH keys instead of passwords
- Implement fail2ban or similar for brute-force protection
- Regular key rotation
- Use strong key algorithms (Ed25519, RSA 4096-bit)
- Multi-factor authentication (Google Authenticator, Duo)

## Future Prospects

SSH continues to evolve with modern security requirements:

### Emerging Trends

#### Post-Quantum Cryptography

- Research into quantum-resistant algorithms
- Preparation for quantum computing threats
- Hybrid approaches combining current and post-quantum algorithms

#### Zero Trust Security

- Certificate-based authentication
- Short-lived credentials
- Context-aware access control

#### Cloud-Native Integration

- Better integration with cloud identity providers
- Ephemeral SSH access
- Session recording and audit trails

### Modern Alternatives and Complements

#### Mosh (Mobile Shell)

- Better performance over high-latency connections
- Automatic reconnection
- Local echo for better responsiveness

#### Tailscale/WireGuard

- Modern VPN alternatives
- Zero-configuration mesh networks
- Complements SSH for secure access

#### SSH Certificates

- Centralized key management
- Automatic expiration
- Role-based access control

### Standardization Efforts

- Ongoing IETF work on protocol improvements
- Enhanced security algorithms
- Better support for modern authentication methods

## Useful Resources

- [OpenSSH Official Documentation](https://www.openssh.com/)
- [SSH Protocol RFCs](https://www.ietf.org/rfc/rfc4251.txt)
- [SSH Academy](https://www.ssh.com/academy/ssh)

## Contributing

Feel free to submit issues or pull requests with additional tips and tricks!

## License

This project is licensed under CC0 1.0 Universal - see the LICENSE file for details.
