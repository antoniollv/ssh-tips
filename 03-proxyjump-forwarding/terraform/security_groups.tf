# Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name        = "ssh-tips-bastion-sg"
  description = "Security group for SSH bastion host"
  vpc_id      = aws_vpc.main.id

  # SSH access from allowed CIDR
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
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
    Name = "ssh-tips-bastion-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "ssh-tips-rds-sg"
  description = "Security group for RDS MariaDB"
  vpc_id      = aws_vpc.main.id

  # MySQL access only from bastion
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "MySQL access from bastion only"
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
    Name = "ssh-tips-rds-sg"
  }
}
