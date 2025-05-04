
# Elastic IP for the ALB (to use in certificate)
resource "aws_eip" "alb" {
  count  = var.create_eip ? 1 : 0
  domain = "vpc"
  
  tags = merge(
    {
      Name = "${var.environment}-alb-eip"
    },
    var.tags
  )
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.environment}-alb-sg"
    },
    var.tags
  )
}

# Self-signed certificate for ALB
resource "tls_private_key" "self_signed" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "self_signed" {
  depends_on = [aws_eip.alb]
  
  private_key_pem = tls_private_key.self_signed.private_key_pem

  subject {
    common_name  = var.certificate_domain
    organization = var.certificate_organization
  }

  ip_addresses = concat(
    var.certificate_ip_addresses,
    var.create_eip ? [aws_eip.alb[0].public_ip] : []
  )

  validity_period_hours = 8760
  early_renewal_hours = 720
  is_ca_certificate = true


  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}

resource "aws_acm_certificate" "self_signed" {
  private_key      = tls_private_key.self_signed.private_key_pem
  certificate_body = tls_self_signed_cert.self_signed.cert_pem

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name = "${var.environment}-self-signed-cert"
    },
    var.tags
  )
}

# Application Load Balancer
resource "aws_lb" "devlb" {
  name               = "${var.environment}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    {
      Name = "${var.environment}-alb"
    },
    var.tags
  )
}

# Target Group for ALB
resource "aws_lb_target_group" "ec2" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    {
      Name = "${var.environment}-target-group"
    },
    var.tags
  )
}

# HTTP Listener 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.devlb.arn
  port              = "80"
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.redirect_http_to_https && var.enable_https ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.redirect_http_to_https && var.enable_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.ec2.arn
    }
  }
}

# HTTPS Listener with self-signed certificate
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0
  
  load_balancer_arn = aws_lb.devlb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate.self_signed.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2.arn
  }
}