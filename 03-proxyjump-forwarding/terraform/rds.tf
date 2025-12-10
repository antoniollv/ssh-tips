# Generate random password for RDS
resource "random_password" "db_password" {
  length  = 16
  special = true
  # Avoid characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "ssh-tips-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "ssh-tips-db-subnet-group"
  }
}

# RDS MariaDB Instance
resource "aws_db_instance" "mariadb" {
  identifier     = "ssh-tips-mariadb"
  engine         = "mariadb"
  engine_version = "10.11"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  storage_type          = "gp2"
  storage_encrypted     = true
  max_allocated_storage = 100

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Backup and maintenance
  backup_retention_period = 0 # No backups for demo (reduce costs)
  skip_final_snapshot     = true
  deletion_protection     = false

  # Publicly accessible (set to false for security)
  publicly_accessible = false

  # Enable automated minor version upgrades
  auto_minor_version_upgrade = false

  tags = {
    Name = "ssh-tips-mariadb"
  }
}

# Store database credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "ssh-tips/case02-database-credentials"
  description             = "Database credentials for Case 2 - SSH Database Tunnel"
  recovery_window_in_days = 0 # Immediate deletion for demo purposes

  tags = {
    Name = "ssh-tips-case02-db-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    bastion_public_ip = aws_eip.bastion.public_ip
    rds_endpoint      = aws_db_instance.mariadb.endpoint
    rds_address       = aws_db_instance.mariadb.address
    db_name           = var.db_name
    db_username       = var.db_username
    db_password       = random_password.db_password.result
    db_port           = 3306
    ssh_user          = "ec2-user"
  })
}
