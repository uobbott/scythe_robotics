output "ec2_ip_address" {
  description = "The private IP address of the first EC2 instance"
  value       = module.web_servers.private_ips[0]
}

output "alb_dns_name_raw" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
}