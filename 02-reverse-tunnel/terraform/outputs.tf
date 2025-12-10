output "ec2_public_ip" {
  description = "Public IP of the EC2 bastion"
  value       = aws_eip.bastion.public_ip
}

output "ec2_instance_id" {
  description = "Instance ID of the EC2 bastion"
  value       = aws_instance.bastion.id
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.bastion.public_dns
}

output "demo_url" {
  description = "URL to access the demo (reverse tunnel endpoint)"
  value       = "http://${aws_eip.bastion.public_ip}:${var.demo_port}"
}

output "ssh_connection_command" {
  description = "SSH command to connect to the bastion"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.bastion.public_ip}"
}

output "reverse_tunnel_command" {
  description = "Command to establish the reverse SSH tunnel"
  value       = "ssh -N -R ${var.demo_port}:localhost:${var.demo_port} ec2-user@${aws_eip.bastion.public_ip}"
}

output "security_group_id" {
  description = "Security Group ID for the bastion"
  value       = aws_security_group.bastion.id
}
