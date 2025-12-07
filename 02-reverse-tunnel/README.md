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
          port 8080              reverse      port 8080
```

### Components

1. **Local Machine**
   - Runs crazy-bat (web server with netcat on port 8080)
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

## 🚀 Step-by-Step Demonstration

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
ExecStart=/usr/bin/ssh -N -R 8080:localhost:8080 -o ServerAliveInterval=60 -o ServerAliveCountMax=3 ec2-user@<ec2-public-ip> -i /path/to/ssh-key.pem
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
2. **Local verification:** Show that crazy-bat is running on `localhost:8080`
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

- **How does `-R 8080:localhost:8080` work?**
  - The EC2 server listens on its port 8080
  - When someone connects, SSH redirects traffic to the local machine's port 8080
  
- **Why systemd?**
  - Auto-recovery if SSH connection is lost
  - Centralized logging (`journalctl -u reverse-tunnel`)
  - Consistent management like any other system service

- **Advanced alternative:** Mention `autossh` for production environments (documented in `99-docs/README_autossh.md`)

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
# Record tunnel configuration
asciinema rec demo-reverse-tunnel-setup.cast

# Record complete demonstration
asciinema rec demo-reverse-tunnel-live.cast
```

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
ssh ec2-user@<ec2-public-ip> 'sudo netstat -tlnp | grep 8080'

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

## 📝 Presenter Notes

- **Estimated time:** 12 minutes
- **Prerequisites verified before demo:**
  - ✅ AWS infrastructure deployed
  - ✅ crazy-bat running locally
  - ✅ SSH tunnel active and verified
  - ✅ Public URL shared with audience
- **Backup plan:** Asciinema recording ready to play if live demo fails
