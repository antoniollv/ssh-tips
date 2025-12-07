# SSH Tips & Tricks - Presentation Script

## 📋 General Information

**Duration:** 40 minutes  
**Format:** Remote presentation via Teams  
**Audience:** IT Professionals (developers, sysadmins, DevOps) with SSH knowledge  
**Objective:** Demonstrate advanced SSH capabilities through live practical demonstrations

## 🎯 Presentation Structure

### [01. Introduction](01-introduction/) (2 minutes)

Brief presentation of SSH and *overview* of the practical cases to be demonstrated.

**Topics to cover:**

- What is SSH beyond remote access?
- Advanced capabilities: tunneling, forwarding, X11
- Introduction to the 3 practical cases

📁 **Resources:** [Complete initial presentation](01-introduction/README_introduction.md)

---

### [02. Case 1: The Server That Doesn't Exist](02-reverse-tunnel/) (12 minutes)

#### Reverse SSH Tunnel with Crazy-Bat + Systemd

**Concept:** Web server accessible from the internet that is physically on your local machine, without a public IP.

**Demonstrated techniques:**

- Remote Port Forwarding (`ssh -R`)
- Tunnel management with systemd
- Web server with netcat (crazy-bat)

**Architecture:**

```text
Internet → AWS EC2 (public IP) ← SSH Tunnel ← Local Machine (crazy-bat)
          port 8080              reverse      port 8080
```

**Empirical Demonstration:** Stop the local service and watch the public website go down.

📁 **Resources:** [Complete Case 1 documentation](02-reverse-tunnel/)

---

### [03. Case 2: Bastion Jump + Private Service Access](03-proxyjump-forwarding/) (12 minutes)

#### ProxyJump + Port Forwarding Integrated

**Concept:** Access a web service on a private server (no public IP) by jumping through a bastion, all in a single command.

**Demonstrated techniques:**

- ProxyJump (`ssh -J`)
- Local Port Forwarding (`ssh -L`)
- Optimized `~/.ssh/config` configuration

**Architecture:**

```text
Laptop → Bastion (public IP) → Private Server (nginx/crazy-bat)
         ssh -J                 private IP only
         ssh -L 8080:localhost:80
```

**Result:** Access `http://localhost:8080` in local browser and see the private server's service.

📁 **Resources:** [Complete Case 2 documentation](03-proxyjump-forwarding/)

---

### [04. Case 3: The Magic Window](04-x11-forwarding/) (10 minutes)

#### X11 Forwarding with Remote CPU Monitor

**Concept:** Run graphical application on AWS but see it on local screen. Demonstrate in real-time how the remote server's CPU spikes.

**Demonstrated techniques:**

- X11 Forwarding (`ssh -X`)
- Remote graphical application execution
- Real-time visual monitoring

**Architecture:**

```text
Laptop (X11 client) ← SSH + X11 ← AWS EC2 (X11 server + GUI app)
local window                     htop/xeyes/stress-ng
```

**Empirical Demonstration:** Launch stress test on AWS and watch on your local screen as CPU jumps from 5% to 100%.

📁 **Resources:** [Complete Case 3 documentation](04-x11-forwarding/)

---

### [05. Closing and Additional Cases](05-closing/) (3 minutes)

**Quick mention of other useful cases:**

- **Jailed SSH users** (chroot + SFTP only)
- **Legacy SSH algorithms** for connecting to old systems
- **Dynamic SOCKS Proxy** (`ssh -D`)
- **Other capabilities:** SCP, SFTP, rsync over SSH

📁 **Resources:** [Additional documentation](99-docs/)

---

### 06. Q&A (1 minute)

Quick questions from the audience.

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
- ✅ [Asciinema](https://asciinema.org) recordings as backup
- ✅ Detailed documentation in English and Spanish
- ✅ Additional cases not demonstrated live

---

## 📝 Presenter Notes

### Plan B

Each case has *asciinema* recordings as backup in case of technical failures.

### Timing

- Maintain pace: maximum 12 min per case
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
- [Asciinema](https://asciinema.org/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## 📄 License

This project is licensed under CC0 1.0 Universal - see [LICENSE](LICENSE) file for details.
