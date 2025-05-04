output "instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.web[*].id
}

output "instance_arns" {
  description = "The ARNs of the EC2 instances"
  value       = aws_instance.web[*].arn
}

output "private_ips" {
  description = "The private IP addresses of the EC2 instances"
  value       = aws_instance.web[*].private_ip
}

output "security_group_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "security_group_name" {
  description = "The name of the EC2 security group"
  value       = aws_security_group.ec2.name
}

output "private_key" {
  value     = tls_private_key.uto_key.private_key_pem
  sensitive = true
}

output "key_name" {
  description = "The name of the generated SSH key pair"
  value       = aws_key_pair.generated_key.key_name
}