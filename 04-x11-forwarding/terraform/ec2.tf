# Security Group for X11 Server
resource "aws_security_group" "x11_server" {
  name        = "ssh-tips-x11-server-sg"
  description = "Security group for X11 forwarding server"
  vpc_id      = aws_vpc.main.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "ssh-tips-x11-server-sg"
  }
}

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

resource "aws_key_pair" "x11_server" {
  key_name   = "ssh-tips-x11-key"
  public_key = var.ssh_public_key

  tags = {
    Name = "ssh-tips-x11-key"
  }
}

# X11 Server EC2 Instance
resource "aws_instance" "x11_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.x11_instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.x11_server.key_name

  vpc_security_group_ids = [aws_security_group.x11_server.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Install X11 authentication utilities
              yum install -y xorg-x11-xauth
              
              # Install lightweight X11 demo applications
              yum install -y xeyes xterm
              
              # Configure SSH for X11 forwarding
              sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
              sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config
              sed -i 's/#X11UseLocalhost yes/X11UseLocalhost yes/' /etc/ssh/sshd_config
              
              # Enable TCP keepalive for SSH
              echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
              echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
              
              # Restart SSH service
              systemctl restart sshd
              
              # Create a test file for demo
              echo "X11 Forwarding Demo Server" > /home/ec2-user/welcome.txt
              chown ec2-user:ec2-user /home/ec2-user/welcome.txt
              
              # Create CPU load generator script for demo
              cat > /home/ec2-user/cpu-load.sh << 'SCRIPT'
#!/bin/bash
# CPU Load Generator for X11 Demo
echo "Starting CPU load generation on all cores..."
CORES=$(nproc)
cpu_load() {
    while true; do
        echo "scale=5000; a(1)*4" | bc -l > /dev/null 2>&1
    done
}
for i in $(seq 1 $CORES); do
    cpu_load &
done
echo "CPU load started. Run 'top' in xterm to see the load."
echo "To stop: killall cpu-load.sh"
wait
SCRIPT
              
              chmod +x /home/ec2-user/cpu-load.sh
              chown ec2-user:ec2-user /home/ec2-user/cpu-load.sh
              EOF

  tags = {
    Name = "ssh-tips-x11-server"
  }
}

# Elastic IP for X11 Server
resource "aws_eip" "x11_server" {
  instance = aws_instance.x11_server.id
  domain   = "vpc"

  tags = {
    Name = "ssh-tips-x11-server-eip"
  }
}
