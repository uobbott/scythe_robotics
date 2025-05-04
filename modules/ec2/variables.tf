variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "name" {
  description = "Name to use for the EC2 instances"
  type        = string
  default     = "web"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to place the EC2 instances in (must be private subnets)"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID of the ALB (required)"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group to attach instances to"
  type        = string
  default     = null
}

variable "enable_ssh" {
  description = "Whether to allow SSH access to the instances"
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access (used only if enable_ssh=true and bastion_sg_id is null)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_sg_id" {
  description = "Security group ID of a bastion host for SSH access (used only if enable_ssh=true)"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp2"
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root volume"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data to provide when launching the instance"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}