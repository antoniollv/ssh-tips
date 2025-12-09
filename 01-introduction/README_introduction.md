# Introduction - SSH Tips & Tricks

## Prerequisites: AWS Setup for GitHub Actions

AWS base infrastructure setup.

### On GitHub

1. Create `environment` `poc` in the GitHub repository with the following secrets
   - `AWS_ACCESS_KEY_ID`: AWS credentials for initial setup
   - `AWS_SECRET_ACCESS_KEY`: AWS credentials for initial setup

2. Run the workflow **Setup AWS Requirements** from GitHub Actions
   The workflow will automatically create:
   - S3 bucket for Terraform state
   - IAM role with OIDC for GitHub Actions
   - Creates and adds secrets in AWS

3. Add the `AWS_ROLE_ARN` secret (found in *AWS Secret Manager*, `TF_STATE_BUCKET`) to the `poc` environment

4. Remove temporary credentials (workflows will use OIDC) (optional)

---

## What is SSH Beyond Remote Access?

SSH (Secure Shell) is a cryptographic network protocol developed in 1995 by Tatu Ylönen. Most of us know it as the tool to connect to remote servers:

```bash
ssh user@server
```

But SSH is **much more** than that. It's a very versatile tool for secure connectivity.

## Brief History

- **SSH-1** (1995): Original protocol created to replace Telnet, rlogin, rsh
- **SSH-2** (2006): Current standard (RFC 4251-4254) with improved security
- **OpenSSH** (1999): Most widely used open-source implementation

## Advanced SSH Capabilities

### 🔀 Tunneling (Port Forwarding)

SSH can create secure tunnels to redirect network traffic:

- **Local Forwarding:** Access remote services locally
- **Remote Forwarding:** Expose local services remotely
- **Dynamic Forwarding:** Create a SOCKS proxy

### 🖥️ X11 Forwarding

Run graphical applications on the server but see them on your local screen.

### 🦘 ProxyJump

Jump through multiple machines to reach remote servers.

### 🔐 Key-Based Authentication

Secure access without passwords using public key cryptography.

## What Will We See Today?

In this presentation we'll demonstrate **3 practical cases** that show the real power of SSH:

### 1️⃣ The Server That Doesn't Exist (12 min)

#### Reverse SSH Tunnel

Access a web server that's on your local machine, from the internet, without having a public IP.

**Techniques:**

- Remote Port Forwarding (`ssh -R`)
- Crazy-bat (web server with netcat)

### 2️⃣ Server Jumping + Private Service (12 min)

#### Integrated ProxyJump + Port Forwarding

Jump through a server AND access a private service

**Techniques:**

- ProxyJump (`ssh -J`)
- Local Port Forwarding (`ssh -L`)

### 3️⃣ The Magic Window (10 min)

#### X11 Forwarding with CPU Monitor

See on your local screen a graphical application running on AWS. Run a stress test and watch the CPU spike in real-time.

**Techniques:**

- X11 Forwarding (`ssh -X`)
- Remote graphical applications
- Visual monitoring

## Highlights

These are not exotic tricks. They're practical tools for:

- **DevOps:** Securely access internal services
- **Development:** Testing with remote services as if they were local
- **Security:** Minimize attack surface (fewer open ports)
- **Productivity:** Simplify complex workflows

## Ready?

Let's begin with the first case: **The Server That Doesn't Exist**

👉 **[Continue to Case 1: Reverse SSH Tunnel](../02-reverse-tunnel/)**

---

## Additional Resources

For deeper SSH basics, check the [complete SSH Tips documentation](../99-docs/README_tips.md) covering:

- Server and client configuration
- Key generation
- SCP and SFTP
- `~/.ssh/config` configuration
- Security best practices
