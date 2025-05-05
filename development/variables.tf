variable "environment" {
  description = "Environment name"
  type        = string
  default     = "uto-dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "Uto devOps assignment"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to use for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnets"
  type        = bool
  default     = false 
}

# EC2
variable "web_instance_count" {
  description = "Number of web server instances to create"
  type        = number
  default     = 1
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t2.micro"
}



variable "enable_ssh_access" {
  description = "Whether to enable SSH access to EC2 instances"
  type        = bool
  default     = false 
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access (only used if enable_ssh_access=true)"
  type        = list(string)
  default     = ["0.0.0.0/0"] 
}