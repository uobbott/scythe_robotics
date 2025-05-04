variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default = "development"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to place the ALB in"
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
  default     = "/"
}

variable "redirect_http_to_https" {
  description = "Whether to redirect HTTP traffic to HTTPS"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ARN of ACM certificate to use with the ALB (if you want to use an existing certificate)"
  type        = string
  default     = null
}

variable "certificate_domain" {
  description = "Domain name for the self-signed certificate"
  type        = string
  default     = "scytherobotics.com"
}

variable "certificate_organization" {
  description = "Organization name for the self-signed certificate"
  type        = string
  default     = "scythe robotics"
}

variable "certificate_ip_addresses" {
  description = "List of IP addresses for the self-signed certificate (for ALB)"
  type        = list(string)
  default     = []
}

variable "enable_https" {
  description = "Whether to enable HTTPS listener with the self-signed certificate"
  type        = bool
  default     = true
}

variable "create_eip" {
  description = "Whether to create an Elastic IP for the ALB"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}