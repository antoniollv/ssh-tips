variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH into the bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change to your IP for production
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ssh-tips-reverse-tunnel"
}

variable "demo_port" {
  description = "Port for the reverse tunnel demo"
  type        = number
  default     = 80
}
