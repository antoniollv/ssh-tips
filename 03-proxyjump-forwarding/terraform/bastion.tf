# Get latest Amazon Linux 2023 AMI
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

# Generate SSH key pair if not provided
resource "tls_private_key" "bastion_key" {
  count     = var.ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "ssh-tips-bastion-key"
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.bastion_key[0].public_key_openssh

  tags = {
    Name = "ssh-tips-bastion-key"
  }
}

# Bastion EC2 Instance
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.bastion.key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mysql
              
              # Enable TCP keepalive for SSH
              echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
              echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
              systemctl restart sshd
              EOF

  tags = {
    Name = "ssh-tips-bastion"
  }
}

# Elastic IP for Bastion
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "ssh-tips-bastion-eip"
  }
}
