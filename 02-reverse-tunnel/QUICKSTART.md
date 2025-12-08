# Quick Start - Case 1: Reverse SSH Tunnel

## ⚡ TL;DR

Expose your local web service to the internet without a public IP using AWS EC2 and reverse SSH tunnels.

## 🚀 5-Minute Setup

### 1. Deploy Infrastructure

**Via GitHub Actions (Recommended):**
```bash
# Go to: https://github.com/antoniollv/ssh-tips/actions
# Select: "02 - Reverse Tunnel Infrastructure"
# Click: "Run workflow"
# Input: environment = poc, action = apply
```

**Or via Terraform:**
```bash
cd 02-reverse-tunnel/terraform
terraform init
terraform apply
# Note the ec2_public_ip output
```

### 2. Run Demo

```bash
cd 02-reverse-tunnel

# Setup web server
./setup-crazy-bat.sh

# Establish tunnel (replace with your EC2 IP)
./setup-tunnel.sh 34.254.122.190

# In another terminal: verify setup
./verify-demo.sh 34.254.122.190
```

### 3. Test It

```bash
# From any device with internet
curl http://34.254.122.190:8080
```

You should see the crazy-bat web page served from your **local machine**! 🎉

### 4. Cleanup

```bash
# Stop everything
./cleanup.sh

# Destroy AWS infrastructure
# Via GitHub Actions or:
cd terraform
terraform destroy
```

## 📹 Record for Presentation

```bash
cd demos
./record-demo.sh 34.254.122.190

# Select option 1 for complete automated demo
# Recording saved to: demos/case01-complete-demo.cast

# Playback
asciinema play demos/case01-complete-demo.cast
```

## 🔧 What Each Script Does

| Script | Purpose | Duration |
|--------|---------|----------|
| `setup-crazy-bat.sh` | Starts web server on port 8085 | ~30s |
| `setup-tunnel.sh` | Creates SSH tunnel to EC2 | ~5s |
| `verify-demo.sh` | Validates complete setup | ~10s |
| `install-systemd-service.sh` | Makes tunnel persistent | ~5s |
| `cleanup.sh` | Stops and removes everything | ~5s |

## 🎯 Port Mapping

```
Internet → EC2:8080 ← [SSH Tunnel] ← localhost:8085
           (public)                    (crazy-bat)
```

## 📋 Prerequisites

- ✅ AWS Account with access to EC2
- ✅ GitHub repository secrets configured (for Actions)
- ✅ Docker installed locally
- ✅ SSH key at `~/.ssh/id_rsa`
- ✅ (Optional) asciinema for recording

## 💡 Common Commands

```bash
# Check if tunnel is running
ps aux | grep "ssh.*-R.*8080"

# Check if crazy-bat is running
docker ps | grep crazy-bat

# View systemd service logs
sudo journalctl -u reverse-tunnel -f

# Test local service
curl http://localhost:8085

# Test public URL
curl http://<EC2_IP>:8080
```

## ⚠️ Troubleshooting

**Tunnel won't connect:**
```bash
# Test basic SSH
ssh -i ~/.ssh/id_rsa ec2-user@<EC2_IP>

# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
```

**Public URL not accessible:**
```bash
# Verify Security Group allows port 8080
# Check GatewayPorts in EC2:
ssh ec2-user@<EC2_IP> 'grep GatewayPorts /etc/ssh/sshd_config'
```

**crazy-bat not responding:**
```bash
# Check container status
docker ps -a | grep crazy-bat

# Rebuild if needed
cd ~/DevOps/crazy-bat
docker build -t crazy-bat .
```

## 📚 Full Documentation

See [README.md](README.md) for complete documentation including:
- Architecture details
- Manual step-by-step guide
- systemd configuration
- Security considerations
- Alternative solutions

---

**Presentation ready in 5 minutes!** 🎬
