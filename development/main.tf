# VPC Module
module "vpc" {
  source = "git::https://github.com/uobbott/scythe_robotics.git//modules/vpc"

  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}

# ALB Module
module "alb" {
  source = "git::https://github.com/uobbott/scythe_robotics.git//modules/alb"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  internal          = false
  
  # Configure HTTPS with self-signed certificate 
  redirect_http_to_https     = true
  enable_https               = true
  certificate_domain         = "${var.environment}.scythe.com"
  certificate_organization   = "${var.project} Organization"
  # Create EIP and add it to the certificate
  create_eip                 = true
  certificate_ip_addresses   = []  # Will be populated by the module
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}

# EC2 Module
module "web_servers" {
  source = "git::https://github.com/uobbott/scythe_robotics.git//modules/ec2"

  environment    = var.environment
  name           = "web"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  instance_count = var.web_instance_count
  ami_id         = data.aws_ami.amazon_linux.id
  instance_type  = var.web_instance_type
  key_name       = module.web_servers.key_name
  
  #EC2 only accepts traffic from ALB
  alb_sg_id            = module.alb.alb_security_group_id
  alb_target_group_arn = module.alb.target_group_arn
  
  # SSH access configuration
  enable_ssh        = var.enable_ssh_access
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Uto's DevOps Application ${var.environment} Environment</h1>" > /var/www/html/index.html
    echo "<p>Server ID: $(hostname)</p>" >> /var/www/html/index.html
  EOF
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}