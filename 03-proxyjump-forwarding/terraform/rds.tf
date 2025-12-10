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

# Null resource to populate database with sample data
resource "null_resource" "populate_db" {
  depends_on = [aws_db_instance.mariadb, aws_instance.bastion, aws_secretsmanager_secret_version.db_credentials]

  # Trigger on RDS endpoint change
  triggers = {
    db_endpoint = aws_db_instance.mariadb.endpoint
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ssh_private_key != "" ? var.ssh_private_key : tls_private_key.bastion_key[0].private_key_pem
      host        = aws_eip.bastion.public_ip
    }

    inline = [
      "# Wait for RDS to be fully available",
      "sleep 60",
      "",
      "# Create SQL file with sample data",
      "cat > /tmp/populate_db.sql << 'EOSQL'",
      "-- Create employees table",
      "CREATE TABLE IF NOT EXISTS employees (",
      "  id INT AUTO_INCREMENT PRIMARY KEY,",
      "  name VARCHAR(100) NOT NULL,",
      "  department VARCHAR(50) NOT NULL,",
      "  salary DECIMAL(10, 2) NOT NULL,",
      "  hire_date DATE NOT NULL",
      ");",
      "",
      "-- Create products table",
      "CREATE TABLE IF NOT EXISTS products (",
      "  id INT AUTO_INCREMENT PRIMARY KEY,",
      "  name VARCHAR(100) NOT NULL,",
      "  category VARCHAR(50) NOT NULL,",
      "  price DECIMAL(10, 2) NOT NULL,",
      "  stock INT NOT NULL",
      ");",
      "",
      "-- Insert sample employees",
      "INSERT INTO employees (name, department, salary, hire_date) VALUES",
      "('Alice Johnson', 'Engineering', 95000.00, '2020-01-15'),",
      "('Bob Smith', 'Engineering', 85000.00, '2019-03-22'),",
      "('Carol Williams', 'Marketing', 75000.00, '2021-06-10'),",
      "('David Brown', 'Sales', 70000.00, '2018-11-05'),",
      "('Eve Davis', 'Engineering', 105000.00, '2017-09-12'),",
      "('Frank Miller', 'HR', 65000.00, '2020-02-28'),",
      "('Grace Wilson', 'Engineering', 92000.00, '2019-07-19'),",
      "('Henry Moore', 'Marketing', 78000.00, '2021-01-08'),",
      "('Iris Taylor', 'Sales', 72000.00, '2020-05-14'),",
      "('Jack Anderson', 'Engineering', 88000.00, '2018-12-03');",
      "",
      "-- Insert sample products",
      "INSERT INTO products (name, category, price, stock) VALUES",
      "('Laptop Pro 15', 'Electronics', 1299.99, 45),",
      "('Wireless Mouse', 'Electronics', 29.99, 150),",
      "('USB-C Cable', 'Accessories', 12.99, 300),",
      "('Mechanical Keyboard', 'Electronics', 89.99, 75),",
      "('Monitor 27 inch', 'Electronics', 349.99, 30),",
      "('Desk Lamp', 'Office', 39.99, 120),",
      "('Office Chair', 'Office', 199.99, 25),",
      "('Notebook A4', 'Stationery', 4.99, 500),",
      "('Pen Set', 'Stationery', 9.99, 200),",
      "('External SSD 1TB', 'Electronics', 129.99, 60);",
      "EOSQL",
      "",
      "# Execute SQL file",
      "mysql -h ${aws_db_instance.mariadb.address} -u ${var.db_username} -p'${random_password.db_password.result}' ${var.db_name} < /tmp/populate_db.sql",
      "",
      "# Cleanup",
      "rm /tmp/populate_db.sql",
      "echo 'Database populated successfully!'"
    ]
  }
}
