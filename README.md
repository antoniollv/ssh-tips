# SSH Tips & Tricks

## 📋 General Information

Talk about some practical use cases of the SSH remote access protocol, beyond its usual usage.

**Duration:** 40 minutes  
**Format:** Remote presentation via Teams  
**Audience:** IT professionals with SSH knowledge  
**Objective:** Showcase SSH capabilities through practical demonstrations

## 🎯 Presentation Structure

### [01. Introduction](01-introduction/README_introduction.md) (2 minutes)

Brief presentation of SSH and overview of the practical cases to be demonstrated.

**Topics to cover:**

- What is SSH beyond remote access?
- Advanced capabilities: tunneling, forwarding, X11
- Introduction to the 3 practical cases

📁 **Resources:** [Initial presentation](01-introduction/README_introduction.md)

---

### [02. Case 1: The Server That Doesn't Exist](02-reverse-tunnel/README.md) (12 minutes)

#### Reverse SSH Tunnel with Crazy-Bat + Systemd

**Concept:** Web server accessible from the internet that is physically on your local machine, without a public IP.

**Techniques demonstrated:**

- Remote Port Forwarding (`ssh -R`)
- Web server with netcat (crazy-bat)

**Architecture:**

```text
Internet → AWS EC2 (public IP) ← SSH Tunnel ← Local Machine (crazy-bat)
          port 8080             reverse      port 8085
       (EC2 public port)                  (local service port)
```

**Empirical test:** Stop the local service and watch how the public website goes down.

📁 **Resources:** [Complete Case 1 documentation](02-reverse-tunnel/README.md)

---

### [03. Case 2: Jumping Through Different Hosts to Access Private Service](03-proxyjump-forwarding/README.md) (12 minutes)

#### Integrated ProxyJump + Port Forwarding

**Concept:** Access a service on a private server (without public IP).

**Techniques demonstrated:**

- ProxyJump (`ssh -J`)
- Local Port Forwarding (`ssh -L`)

**Architecture:**

```text
Local Machine → Bastion (public IP) → Private Server (nginx/crazy-bat)
          ssh -J                  private IP only
          ssh -L 8080:localhost:80
```

**Result:** Access a remote database on localhost.

📁 **Resources:** [Complete Case 2 documentation](03-proxyjump-forwarding/README.md)

---

### [04. Case 3: The Magic Window](04-x11-forwarding/README.md) (10 minutes)

#### X11 Forwarding with Remote CPU Monitor

**Concept:** Run a graphical application on AWS but see it on your local screen. Demonstrate in real-time how the remote server's CPU spikes.

**Techniques demonstrated:**

- X11 Forwarding (`ssh -X`)
- Remote graphical application execution
- Real-time visual monitoring

**Architecture:**

```text
Local Machine (X11 client) ← SSH + X11 ← AWS EC2 (X11 server + GUI app)
local window                          htop/xeyes/stress-ng
```

**Empirical test:** Launch stress test on AWS and watch on your local screen how CPU jumps from 5% to 100%.

📁 **Resources:** [Complete Case 3 documentation](04-x11-forwarding/README.md)

---

### [05. Closing and Additional Cases](05-closing/README.md) (3 minutes)

**Quick mention of other useful cases:**

- **Jailed SSH users** (chroot + SFTP only)
- **Legacy SSH algorithms** for connecting to old systems
- **Dynamic SOCKS Proxy** (`ssh -D`)
- **Tunnel management with systemd**
- **Autossh**
- **Other capabilities:** SCP, SFTP, rsync over SSH

📁 **Resources:** [Additional documentation](99-docs/README_tips.md)

---

### 06. Q&A (1 minute)

Audience questions.

---

## 🛠️ Technical Requirements

### AWS Infrastructure

All resources are automatically deployed with Terraform:

- **Case 1:** 1x EC2 t2.micro + Security Group + Elastic IP
- **Case 2:** 2x EC2 t2.micro + VPC + 2 Subnets + Security Groups + Elastic IP
- **Case 3:** 1x EC2 t2.small + Security Group + Elastic IP

### Local

- Docker (for crazy-bat)
- SSH client with X11 support
- X11 server (native Linux, WSL2 + VcXsrv, or XQuartz on Mac)
- Terraform
- Configured AWS CLI

### GitHub Actions

Workflows for automatic deploy/destroy of AWS infrastructure.

---

## 📚 Shared Resources

At the end of the presentation, this complete repository is shared with:

- ✅ Terraform code for each case
- ✅ Configuration scripts
- ✅ [asciinema](https://asciinema.org) recordings
- ✅ Detailed documentation in English and Spanish
- ✅ Additional cases not demonstrated live

---

## 📝 Presenter Notes

### Plan B

Each case has asciinema recordings as backup in case of technical failures.

### Timing

- Keep pace: maximum 12 min per case
- Reserve time for unexpected issues
- Questions at the end, not during demos

### Key Messages

1. **SSH is much more than remote access:** tunneling, forwarding, X11
2. **Real practical cases:** not exotic tricks, but useful tools
3. **Automation:** systemd, Terraform, IaC
4. **Available documentation:** everything in this repository for deeper learning

---

## 🔗 Useful Links

- [OpenSSH Official Documentation](https://www.openssh.com/)
- [Crazy-Bat Project](https://github.com/antoniollv/crazy-bat)
- [asciinema](https://asciinema.org/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## 📄 License

This project is licensed under CC0 1.0 Universal - see [LICENSE](LICENSE) file for details.
