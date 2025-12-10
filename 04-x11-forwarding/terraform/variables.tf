variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "x11_instance_type" {
  description = "EC2 instance type for X11 server"
  type        = string
  default     = "t2.micro"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
}
