# Introduction - SSH Tips & Tricks

## Prerequisites: AWS Configuration for GitHub Actions

Before starting, you need to configure the base AWS infrastructure.

### Option 1: Using GitHub Actions (Recommended)

1. Configure the `poc` environment in your GitHub repository
2. Add these secrets to the `poc` environment:
   - `AWS_ACCESS_KEY_ID`: Temporary AWS credentials for initial setup
   - `AWS_SECRET_ACCESS_KEY`: Temporary AWS credentials for initial setup
3. Run the **Setup AWS Requirements** workflow from GitHub Actions
4. The workflow will automatically create:
   - S3 bucket for Terraform state
   - IAM role with OIDC for GitHub Actions
5. Add the generated secrets (`AWS_ROLE_ARN`, `TF_STATE_BUCKET`) to the `poc` environment
6. Remove temporary credentials (workflows will use OIDC)

### Option 2: Local setup with scripts

**Requirements:** AWS CLI configured with admin credentials

```bash
cd 01-introduction
cp env.local.template env.local
# Edit env.local with your values:
# - AWS_REGION=eu-west-1, TF_STATE_BUCKET
# - GITHUB_ORG, GITHUB_REPO

# Create S3 bucket
chmod +x create-s3-backend.sh
./create-s3-backend.sh

# Create IAM role for GitHub Actions
chmod +x create-github-iam-role.sh
./create-github-iam-role.sh
```

Add the secrets shown in the script output to your GitHub repository.

---

## What is SSH beyond remote access?

SSH (Secure Shell) is a cryptographic network protocol developed in 1995 by Tatu Ylönen. Most of us know it as the tool to connect to remote servers:

```bash
ssh user@server
```

But SSH is **much more** than that. It's a Swiss Army knife for secure connectivity.

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

Jump through multiple bastions to reach internal servers.

### 🔐 Key-Based Authentication

Secure access without passwords using public-key cryptography.

## What Will We See Today?

In this presentation we will demonstrate **3 practical cases** that show the real power of SSH:

### 1️⃣ The Server That Doesn't Exist (12 min)

#### Reverse SSH Tunnel with Systemd

Access a web server that's on your local machine, from the internet, without having a public IP.

**Techniques:**

- Remote Port Forwarding (`ssh -R`)
- Management with systemd
- Crazy-bat (web server with netcat)

### 2️⃣ Bastion Jump + Private Service (12 min)

#### ProxyJump + Port Forwarding Integrated

Jump through a bastion AND access a private web service, all in a single command.

**Techniques:**

- ProxyJump (`ssh -J`)
- Local Port Forwarding (`ssh -L`)
- `~/.ssh/config` configuration

### 3️⃣ The Magic Window (10 min)

#### X11 Forwarding with CPU Monitor

See on your local screen a graphical application running on AWS. Run a stress test and watch the CPU spike in real-time.

**Techniques:**

- X11 Forwarding (`ssh -X`)
- Remote graphical applications
- Visual monitoring

## Why It Matters

These aren't exotic tricks. They're practical tools for:

- **DevOps:** Securely access internal services
- **Development:** Test with remote services as if they were local
- **Security:** Minimize attack surface (fewer open ports)
- **Productivity:** Simplify complex workflows

## Demonstration Methodology

Each case will include:

✅ **Concept explanation** (2 min)  
✅ **Visual architecture** (1 min)  
✅ **Live demonstration** (7-8 min)  
✅ **Empirical demonstration** (visual surprise)  
✅ **Practical applications** (1 min)

All resources will be available in this repository:

- Terraform code to replicate the infrastructure
- Configuration scripts
- Detailed documentation
- Asciinema recordings

## Ready?

Let's start with the first case: **The Server That Doesn't Exist**

👉 **[Continue to Case 1: Reverse SSH Tunnel](../02-reverse-tunnel/)**

---

## Additional Resources

To dive deeper into basic SSH, check out the [complete SSH Tips documentation](../99-docs/README_tips.md) which covers:

- Server and client configuration
- Key generation
- SCP and SFTP
- `~/.ssh/config` configuration
- Security best practices
