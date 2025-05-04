output "alb_id" {
  description = "The ID of the ALB"
  value       = aws_lb.devlb.id
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.devlb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.devlb.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.devlb.zone_id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.ec2.arn
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "certificate_arn" {
  description = "The ARN of the certificate used by the ALB"
  value       = var.certificate_arn
}