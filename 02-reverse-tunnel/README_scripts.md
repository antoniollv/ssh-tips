# Demo Scripts - Reverse SSH Tunnel

This directory contains automation scripts for the reverse SSH tunnel demonstration.

## 📋 Scripts Overview

All scripts display commands before executing them for demonstration purposes, using color-coded output:

- **🔵 Blue headers**: Section separators
- **🟡 Yellow**: Commands being executed
- **🟢 Green**: Success messages and info
- **🟠 Orange**: Warnings
- **🔴 Red**: Errors

## 🚀 Quick Start

### Option A: Automated Setup (Recommended)

```bash
# 1. Start crazy-bat web server
./setup-crazy-bat.sh

# 2. Start the reverse tunnel (replace with your EC2 IP)
./setup-tunnel.sh 54.123.45.67

# 3. In another terminal, verify everything works
./verify-demo.sh 54.123.45.67

# 4. When done, cleanup
./cleanup.sh
```

### Option B: Systemd Service (Production-like)

```bash
# 1. Start crazy-bat
./setup-crazy-bat.sh

# 2. Install as systemd service (requires sudo)
sudo ./install-systemd-service.sh 54.123.45.67

# 3. Verify
./verify-demo.sh 54.123.45.67

# 4. Cleanup
./cleanup.sh
```

## 📝 Script Details

### `setup-crazy-bat.sh`

Prepares and starts the crazy-bat web server.

**Usage:**

```bash
./setup-crazy-bat.sh [CRAZY_BAT_DIR] [PORT]
```

**Parameters:**

- `CRAZY_BAT_DIR`: Path to crazy-bat repository (default: `$HOME/DevOps/crazy-bat`)
- `PORT`: Port to run the server on (default: `8080`)

**What it does:**

1. Clones crazy-bat if not present
2. Checks Docker installation
3. Stops any existing containers
4. Builds and starts crazy-bat with Docker Compose
5. Verifies the service is accessible on localhost

**Example:**

```bash
./setup-crazy-bat.sh ~/projects/crazy-bat 8080
```

### `setup-tunnel.sh`

Establishes the reverse SSH tunnel manually (foreground process).

**Usage:**

```bash
./setup-tunnel.sh <EC2_PUBLIC_IP> [DEMO_PORT] [SSH_KEY] [LOCAL_SERVICE_PORT]
```

**Parameters:**

- `EC2_PUBLIC_IP`: Public IP of your EC2 instance (required)
- `DEMO_PORT`: Port on EC2 to expose (default: `80`)
- `SSH_KEY`: Path to SSH private key (default: `~/.ssh/id_rsa`)
- `LOCAL_SERVICE_PORT`: Local port where crazy-bat runs (default: `8080`)

**What it does:**

1. Verifies SSH key permissions
2. Tests SSH connectivity to EC2
3. Checks local service is running
4. Verifies EC2 SSHD configuration
5. Establishes the reverse tunnel

**Example:**

```bash
./setup-tunnel.sh 54.123.45.67 80 ~/.ssh/ssh-tips-key.pem 8080
```

**Note:** This runs in the foreground. Press `Ctrl+C` to stop the tunnel.

### `install-systemd-service.sh`

Installs the reverse tunnel as a systemd service (requires root).

**Usage:**

```bash
sudo ./install-systemd-service.sh <EC2_PUBLIC_IP> [DEMO_PORT] [LOCAL_PORT] [SSH_KEY]
```

**Parameters:**

- `EC2_PUBLIC_IP`: Public IP of your EC2 instance (required)
- `DEMO_PORT`: Port on EC2 to expose (default: `80`)
- `LOCAL_PORT`: Local port where crazy-bat runs (default: `8080`)
- `SSH_KEY`: Path to SSH private key (default: `~/.ssh/id_rsa`)

**What it does:**

1. Creates systemd service file from template
2. Configures auto-restart on failure
3. Enables service to start on boot
4. Starts the service

**Example:**

```bash
sudo ./install-systemd-service.sh 54.123.45.67 80 8080 ~/.ssh/ssh-tips-key.pem
```

**Systemd commands:**

```bash
# View status
sudo systemctl status reverse-tunnel

# View logs (follow)
sudo journalctl -u reverse-tunnel -f

# Stop/start/restart
sudo systemctl stop reverse-tunnel
sudo systemctl start reverse-tunnel
sudo systemctl restart reverse-tunnel

# Disable (won't start on boot)
sudo systemctl disable reverse-tunnel
```

### `verify-demo.sh`

Verifies all components of the demo are working correctly.

**Usage:**

```bash
./verify-demo.sh <EC2_PUBLIC_IP> [DEMO_PORT] [SSH_KEY]
```

**Parameters:**

- `EC2_PUBLIC_IP`: Public IP of your EC2 instance (required)
- `DEMO_PORT`: Port to test (default: `80`)
- `SSH_KEY`: Path to SSH private key (default: `~/.ssh/id_rsa`)

**What it checks:**

1. Local service (crazy-bat) is running
2. SSH connection to EC2 works
3. SSH tunnel process is active
4. EC2 is listening on the demo port
5. Public URL is accessible
6. Content matches between local and public URLs

**Example:**

```bash
./verify-demo.sh 54.123.45.67 80 ~/.ssh/ssh-tips-key.pem
```

### `cleanup.sh`

Stops and cleans up all demo components.

**Usage:**

```bash
./cleanup.sh [CRAZY_BAT_DIR]
```

**Parameters:**

- `CRAZY_BAT_DIR`: Path to crazy-bat repository (default: `$HOME/DevOps/crazy-bat`)

**What it does:**

1. Stops systemd service (if running)
2. Kills manual SSH tunnel processes
3. Stops crazy-bat Docker containers
4. Shows remaining listening ports

**Example:**

```bash
./cleanup.sh ~/projects/crazy-bat
```

## 🎬 Demo Workflow

### Pre-Demo Checklist

```bash
# 1. Make scripts executable
chmod +x *.sh

# 2. Deploy AWS infrastructure with GitHub Actions or:
cd terraform
terraform init -backend-config="bucket=YOUR_BUCKET" \
               -backend-config="key=ssh-tips/02-reverse-tunnel/terraform.tfstate" \
               -backend-config="region=eu-west-1"
terraform apply

# 3. Note the EC2 public IP from terraform output
terraform output ec2_public_ip
```

### During Demo

```bash
# Show starting crazy-bat
./setup-crazy-bat.sh

# Show establishing tunnel
./setup-tunnel.sh <EC2_IP>

# In another terminal, verify
./verify-demo.sh <EC2_IP>

# Share the URL with audience
# Show stopping/starting crazy-bat to demonstrate the tunnel
docker stop $(docker ps -q --filter ancestor=crazy-bat)
docker start $(docker ps -aq --filter ancestor=crazy-bat)
```

### Post-Demo

```bash
# Cleanup
./cleanup.sh

# Destroy AWS infrastructure
cd terraform
terraform destroy
```

## 🎨 Color Output

Scripts use ANSI color codes for better visibility:

- **Cyan/Yellow**: Commands being executed
- **Green**: Success messages
- **Yellow**: Warnings
- **Red**: Errors
- **Blue**: Section headers

To disable colors, redirect to a file or modify the color variables in each script.

## 🔧 Troubleshooting

### "Permission denied" on scripts

```bash
chmod +x *.sh
```

### SSH key permissions error

```bash
chmod 600 ~/.ssh/your-key.pem
```

### Docker not found

Install Docker:

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install docker.io docker-compose

# Or use Docker official installation
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Port 8080 already in use

```bash
# Find what's using the port
sudo netstat -tlnp | grep :8080
# or
sudo ss -tlnp | grep :8080

# Kill the process or change the port in scripts
```

### Tunnel disconnects frequently

Consider using `autossh` instead (see `../99-docs/README_autossh.md`) or increase the `ServerAliveInterval` in the scripts.

## 📚 Additional Resources

- [Main Demo Documentation](./README.md)
- [Terraform Infrastructure](./terraform/README.md)
- [autossh Documentation](../99-docs/README_autossh.md)
- [crazy-bat Project](https://github.com/antoniollv/crazy-bat)
