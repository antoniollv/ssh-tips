# Case 1: The Server That Doesn't Exist

## 🎯 Objective

Demonstrate how to expose a local web service to the internet without having a public IP, using reverse SSH tunnels.

## 📋 Concept

Web server accessible from the internet that is physically on your local machine, without a public IP.

## 🔧 SSH Techniques Demonstrated

- **Remote Port Forwarding** (`ssh -R`): Reverse tunnel from local machine to public server
- **Tunnel management with systemd**: Keep the tunnel active and auto-recoverable
- **Web server with netcat**: Using the [crazy-bat](https://github.com/antoniollv/crazy-bat) project

## 🏗️ Architecture

```text
Internet → AWS EC2 (public IP) ← SSH Tunnel ← Local Machine (crazy-bat)
          port 8080              reverse      port 8085
```

### Components

1. **Local Machine**
   - Runs crazy-bat (web server with netcat on port 8085)
   - Initiates reverse SSH tunnel to EC2
   - Tunnel management via systemd

2. **AWS EC2 (Bastion)**
   - t2.micro instance with public IP
   - Receives SSH connection from local machine
   - Exposes port 8080 to internet
   - Security Group: allows traffic on port 8080

3. **Audience**
   - Accesses `http://<ec2-public-ip>:8080`
   - Sees content served from presenter's local machine

## 🚀 Quick Start with Automated Scripts

The demonstration includes automated scripts that handle all setup and verification steps.

### Prerequisites

1. **AWS Infrastructure Deployed:**

   ```bash
   # Via GitHub Actions (recommended)
   # Go to Actions → "02 - Reverse Tunnel Infrastructure" → Run workflow
   
   # Or manually with Terraform
   cd 02-reverse-tunnel/terraform
   terraform init
   terraform apply
   ```

2. **Get EC2 Public IP:**

   ```bash
   # From Terraform output
   terraform output ec2_public_ip
   
   # Or from AWS Console
   ```

### Automated Demo Execution

```bash
cd 02-reverse-tunnel

# 1. Setup crazy-bat web server (port 8085)
./setup-crazy-bat.sh

# 2. Establish SSH reverse tunnel (8080:localhost:8085)
./setup-tunnel.sh <EC2_PUBLIC_IP>

# 3. Verify complete setup
./verify-demo.sh <EC2_PUBLIC_IP>

# 4. (Optional) Install as systemd service for persistence
./install-systemd-service.sh <EC2_PUBLIC_IP>

# 5. Cleanup when done
./cleanup.sh
```

### Recording with Asciinema

An automated recording script is provided to create consistent demos:

```bash
cd 02-reverse-tunnel/demos

# Interactive menu for recording
./record-demo.sh <EC2_PUBLIC_IP>

# Options:
#   1 - Complete demo (automated)
#   2 - Step 1: Setup crazy-bat
#   3 - Step 2: SSH Tunnel demo
#   4 - Step 3: Verification
```

**What the automated recording shows:**

1. Initial state: Local KO, Remote KO
2. Start crazy-bat: Local OK, Remote KO
3. Establish tunnel: Local OK, Remote OK
4. Kill tunnel: Local OK, Remote KO
5. Stop container: Local KO, Remote KO

**Playback recordings:**

```bash
asciinema play demos/case01-complete-demo.cast
```

See [demos/README_demos.md](demos/README_demos.md) for detailed asciinema usage.

## 🚀 Step-by-Step Demonstration (Manual)

### 1. Preparation (Pre-demonstration)

**On local machine:**

```bash
# Clone crazy-bat
git clone https://github.com/antoniollv/crazy-bat.git
cd crazy-bat

# Start the server
./crazy-bat.sh
```

**Verify it works locally:**

```bash
curl http://localhost:8080
```

### 2. Deploy AWS Infrastructure

```bash
# Run GitHub Actions workflow or manually with Terraform
cd 02-reverse-tunnel/terraform
terraform init
terraform apply
```

**Created resources:**

- EC2 t2.micro with public IP
- Security Group (SSH port 22, HTTP port 8080)
- Elastic IP (optional for static IP)

### 3. Configure SSH Tunnel with Systemd

**Create service file:** `/etc/systemd/system/reverse-tunnel.service`

```ini
[Unit]
Description=SSH Reverse Tunnel to AWS EC2
After=network.target

[Service]
Type=simple
User=<your-user>
ExecStart=/usr/bin/ssh -N -R 8080:localhost:8085 -o ServerAliveInterval=60 -o ServerAliveCountMax=3 ec2-user@<ec2-public-ip> -i /path/to/ssh-key.pem
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Enable and start the service:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable reverse-tunnel.service
sudo systemctl start reverse-tunnel.service
sudo systemctl status reverse-tunnel.service
```

### 4. Live Presentation

**Show the audience:**

1. **Public access:** Share URL `http://<ec2-public-ip>:8080`
2. **Local verification:** Show that crazy-bat is running on `localhost:8085`
3. **Active tunnel:** `sudo systemctl status reverse-tunnel.service`

**Empirical demonstration:**

```bash
# Stop the local service
sudo systemctl stop crazy-bat  # Or stop the process manually

# The audience will see that the public website stops responding
# Restart the service and the website comes back
sudo systemctl start crazy-bat
```

### 5. Technical Explanations During Demo

- **How does `-R 8080:localhost:8085` work?**
  - The EC2 server listens on its port 8080
  - When someone connects, SSH redirects traffic to the local machine's port 8085
  
- **Why `-N` flag?**
  - Prevents execution of remote commands
  - No interactive shell is opened
  - Process only maintains the tunnel (cleaner and more secure)
  
- **Why systemd?**
  - Auto-recovery if SSH connection is lost
  - Centralized logging (`journalctl -u reverse-tunnel`)
  - Consistent management like any other system service

- **Advanced alternative:** Mention `autossh` for production environments (documented in `99-docs/README_autossh.md`)

## 📦 Automation Scripts

All scripts are located in `/02-reverse-tunnel/` and include verbose output with colored commands for presentation clarity.

### setup-crazy-bat.sh

Sets up the crazy-bat web server in a Docker container.

```bash
./setup-crazy-bat.sh
```

**What it does:**

- Clones crazy-bat repository if not present
- Builds Docker image
- Runs container on port 8085 with custom message
- Validates service is responding

**Port:** 8085 (local only, not exposed to internet)

### setup-tunnel.sh

Establishes the SSH reverse tunnel from local machine to EC2.

```bash
./setup-tunnel.sh <EC2_PUBLIC_IP>
```

**What it does:**

- Validates SSH key exists and has correct permissions
- Tests SSH connectivity to EC2
- Verifies local service is running on port 8085
- Establishes reverse tunnel: `-R 8080:localhost:8085`
- Runs in foreground (Ctrl+C to stop)

**Port mapping:** EC2:8080 → localhost:8085

### verify-demo.sh

Comprehensive verification of the complete setup.

```bash
./verify-demo.sh <EC2_PUBLIC_IP>
```

**Verification steps:**

1. ✅ Local service responding on port 8085
2. ✅ SSH connection to EC2 working
3. ✅ Tunnel process is active
4. ✅ EC2 listening on port 8080
5. ✅ Public URL accessible from internet
6. ✅ Content matches (local vs public)

### install-systemd-service.sh

Installs SSH tunnel as a persistent systemd service.

```bash
./install-systemd-service.sh <EC2_PUBLIC_IP>
```

**What it does:**

- Creates `/etc/systemd/system/reverse-tunnel.service`
- Configures auto-restart on failure
- Enables service to start on boot
- Starts the service immediately

**Management:**

```bash
sudo systemctl status reverse-tunnel
sudo systemctl stop reverse-tunnel
sudo systemctl start reverse-tunnel
sudo journalctl -u reverse-tunnel -f
```

### cleanup.sh

Stops and removes all demo components.

```bash
./cleanup.sh
```

**What it does:**

- Stops systemd service (if installed)
- Kills manual SSH tunnel processes
- Stops and removes Docker container
- Verifies no processes listening on ports 8080/8085

## 📦 Required Resources

### AWS

- **EC2 Instance:** t2.micro (Free Tier eligible)
- **Security Group:**
  - Inbound: Port 22 (SSH from your IP)
  - Inbound: Port 8080 (HTTP from 0.0.0.0/0)
- **Key Pair:** For SSH authentication

### Local

- **crazy-bat:** [https://github.com/antoniollv/crazy-bat](https://github.com/antoniollv/crazy-bat)
- **SSH client:** OpenSSH
- **systemd:** For tunnel management (included in modern Linux)

## 🎬 Recording with Asciinema

Create backup recordings for each step:

```bash
cd 02-reverse-tunnel/demos

# Interactive recording helper
./record-demo.sh <EC2_PUBLIC_IP>
```

**Available recordings:**

- Option 1: Complete automated demo (all state transitions)
- Option 2: Setup crazy-bat only
- Option 3: SSH tunnel demonstration
- Option 4: Verification steps

**Playback:**

```bash
# View recording
asciinema play demos/case01-complete-demo.cast

# Slower playback
asciinema play -s 0.5 demos/case01-complete-demo.cast

# Upload to share
asciinema upload demos/case01-complete-demo.cast
```

See [demos/README_demos.md](demos/README_demos.md) for complete asciinema documentation.

## 📁 Project Structure

```text
02-reverse-tunnel/
├── terraform/              # Infrastructure as Code
│   ├── main.tf            # S3 backend, AWS provider
│   ├── ec2.tf             # EC2 instance, Security Group, EIP
│   ├── variables.tf       # Configuration variables
│   └── outputs.tf         # Connection information
├── demos/                 # Asciinema recordings
│   ├── README_demos.md    # Recording guide
│   ├── record-demo.sh     # Interactive recording helper
│   └── *.cast             # Recording files
├── setup-crazy-bat.sh     # Setup web server
├── setup-tunnel.sh        # Establish SSH tunnel
├── verify-demo.sh         # Verify complete setup
├── install-systemd-service.sh  # Install persistent service
├── cleanup.sh             # Cleanup all components
├── reverse-tunnel.service.template  # Systemd template
├── README.md              # This file (English)
└── README_es.md           # Spanish version
```

## 🎯 Presentation Flow

**Recommended timeline:** 12-15 minutes

1. **Introduction (2 min):**
   - Problem: Need to expose local service without public IP
   - Solution: Reverse SSH tunnels

2. **Architecture explanation (2 min):**
   - Show diagram
   - Explain components and data flow

3. **Live demonstration (6 min):**
   - Option A: Run automated recording
   - Option B: Execute scripts live
   - Show state transitions clearly

4. **Technical deep-dive (3 min):**
   - Explain `-R` flag
   - Why `-N` (no remote command)
   - GatewayPorts configuration
   - systemd for persistence

5. **Q&A and alternatives (2 min):**
   - Mention autossh for production
   - Security considerations
   - Use cases

## ⚠️ Troubleshooting

### Tunnel doesn't establish

```bash
# Verify basic SSH connectivity
ssh -i /path/to/key.pem ec2-user@<ec2-public-ip>

# Test tunnel manually
ssh -v -N -R 8080:localhost:8080 ec2-user@<ec2-public-ip> -i /path/to/key.pem
```

### Website not accessible from internet

```bash
# Verify EC2 is listening on 8080
ssh ec2-user@<ec2-public-ip> 'sudo netstat -tlnp | grep :8080'

# Check Security Group in AWS Console
# Ensure GatewayPorts is enabled in EC2's sshd_config
```

### Systemd service fails

```bash
# View detailed logs
sudo journalctl -u reverse-tunnel.service -f

# Verify SSH key permissions
chmod 600 /path/to/key.pem
```

## 🔗 References

- [crazy-bat documentation](https://github.com/antoniollv/crazy-bat)
- [SSH Remote Port Forwarding](https://www.ssh.com/academy/ssh/tunneling/example)
- [systemd Service Files](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Alternative with autossh](../99-docs/README_autossh.md)
- [Asciinema documentation](https://asciinema.org/docs/usage)

## 📝 Presenter Notes

- **Estimated time:** 12-15 minutes
- **Prerequisites verified before demo:**
  - ✅ AWS infrastructure deployed via GitHub Actions
  - ✅ EC2 public IP noted and tested
  - ✅ Local SSH key configured (~/.ssh/id_rsa)
  - ✅ Docker installed and running
  - ✅ Asciinema recording created as backup
- **Backup plan:**
  - Primary: Run automated demo with scripts
  - Fallback: Play pre-recorded `asciinema play demos/case01-complete-demo.cast`
- **Key messages:**
  - Reverse tunnels solve "no public IP" problem
  - SSH is not just for remote shells
  - systemd makes tunnels production-ready
  - Perfect for demos, dev environments, IoT devices

## 🎓 Learning Outcomes

After this demonstration, the audience will understand:

1. **Reverse SSH tunnels** (`-R` flag) and how they differ from local forwarding (`-L`)
2. **Port mapping** between remote and local machines
3. **GatewayPorts** configuration and why it's needed
4. **systemd service management** for persistent tunnels
5. **Practical use cases** for reverse tunnels in real scenarios

## 🔐 Security Considerations

**For production environments:**

- ⚠️ Reverse tunnels expose local services - ensure proper authentication
- ✅ Use key-based authentication, not passwords
- ✅ Restrict SSH access with Security Groups / firewall rules
- ✅ Consider VPN alternatives for permanent solutions
- ✅ Use `autossh` with connection monitoring (see `99-docs/README_autossh.md`)
- ✅ Implement application-level authentication on exposed service
- ⚠️ Be aware of GatewayPorts security implications (allows remote binds)

## 🚀 Real-World Use Cases

1. **Development demos:** Show local work to remote clients/team
2. **IoT devices:** Access home devices behind NAT/firewall
3. **CI/CD webhooks:** Receive webhooks on local development machine
4. **Temporary testing:** Quick public URL for mobile app testing
5. **Remote support:** Access customer's local environment for debugging

---

**Next Case:** [03 - ProxyJump and Port Forwarding](../03-proxyjump-forwarding/)
