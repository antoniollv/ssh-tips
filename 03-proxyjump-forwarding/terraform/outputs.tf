output "secrets_manager_name" {
  description = "AWS Secrets Manager secret name containing all credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_eip.bastion.public_ip
}

output "instructions" {
  description = "Instructions to retrieve credentials and connect"
  value = <<-EOT
    
    📋 RETRIEVE CREDENTIALS:
    aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db_credentials.name} --query SecretString --output text | jq
    
    🔒 SSH TUNNEL COMMAND:
    ssh -i <your-key.pem> -L 3306:<RDS_ADDRESS>:3306 -N ec2-user@${aws_eip.bastion.public_ip}
    
    💾 MYSQL CONNECTION (via tunnel):
    mysql -h 127.0.0.1 -P 3306 -u <DB_USERNAME> -p
    
    🔧 DBEAVER SETTINGS:
    - Host: 127.0.0.1
    - Port: 3306
    - Database: <DB_NAME>
    - Username: <DB_USERNAME>
    - Password: <DB_PASSWORD>
    
    All values available in Secrets Manager: ${aws_secretsmanager_secret.db_credentials.name}
  EOT
}
