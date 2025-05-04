# Security Group for EC2 Instance
resource "aws_security_group" "ec2" {
  name        = "${var.environment}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # Only accept HTTP traffic from the ALB security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
    description     = "HTTP from ALB only"
  }

  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      security_groups = var.bastion_sg_id != null ? [var.bastion_sg_id] : null
      cidr_blocks = var.bastion_sg_id == null ? var.ssh_allowed_cidrs : null
      description = "SSH access"
    }
  }

  # Allow all outbound traffic - needed for yum/httpd installation
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic for internet access via NAT Gateway"
  }

  tags = merge(
    {
      Name = "${var.environment}-ec2-sg"
    },
    var.tags
  )
}

# EC2 Instance - explicitly placed in private subnets
resource "aws_instance" "web" {
  count = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, count.index % length(var.subnet_ids)) # These must be private subnet IDs
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.generated_key.key_name
  
  user_data = var.user_data

  tags = merge(
    {
      Name = "${var.environment}-${var.name}-${count.index + 1}"
    },
    var.tags
  )

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = var.root_volume_encrypted
    
    tags = merge(
      {
        Name = "${var.environment}-${var.name}-${count.index + 1}-root"
      },
      var.tags
    )
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "main" {
  count = 1
  
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.web[0].id
  port             = 80
}

#SSH Keys (needed to create this instance)
resource "tls_private_key" "uto_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "uto-generated-key"
  public_key = tls_private_key.uto_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.uto_key.private_key_pem
  filename = "${path.module}/uto-test-key.pem"
  file_permission = "0600" 
}