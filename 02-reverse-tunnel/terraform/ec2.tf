# Data source to get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source to get default VPC
data "aws_vpc" "default" {
  default = true
}

# SSH Key Pair
resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : file("~/.ssh/id_rsa.pub")

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Security Group for Bastion
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-sg"
  description = "Security group for SSH reverse tunnel bastion"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  # Demo web port (reverse tunnel endpoint)
  ingress {
    description = "HTTP demo port"
    from_port   = var.demo_port
    to_port     = var.demo_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# EC2 Instance - Bastion
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.bastion.key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Configure SSHD for reverse tunneling
              cat >> /etc/ssh/sshd_config <<SSHD_CONFIG
              
              # SSH Reverse Tunnel Configuration
              GatewayPorts yes
              ClientAliveInterval 60
              ClientAliveCountMax 3
              SSHD_CONFIG
              
              # Restart SSH service
              systemctl restart sshd
              
              # Install useful tools
              yum install -y netcat htop
              
              # Create welcome message
              cat > /etc/motd <<MOTD
              =====================================
              SSH Tips - Reverse Tunnel Bastion
              =====================================
              
              This server is configured to accept
              reverse SSH tunnels on port ${var.demo_port}.
              
              Demo URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${var.demo_port}
              
              =====================================
              MOTD
              EOF

  tags = {
    Name = "${var.project_name}-bastion"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for stable public IP
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }

  depends_on = [aws_instance.bastion]
}
