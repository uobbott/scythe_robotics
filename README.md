# AWS Infrastructure with Terraform - Technical Exercise

## Architecture Overview

The infrastructure consists of the following components:

### 1. VPC and Networking (modules/vpc)
- **VPC** with CIDR block 10.0.0.0/16
- **Public Subnets** in two availability zones for the ALB
- **Private Subnets** in two availability zones for EC2 instances
- **Internet Gateway** for public subnet internet access
- **NAT Gateway** for outbound internet access from private subnets
- **Route Tables** for both public and private subnets

### 2. Application Load Balancer (modules/alb)
- **ALB** placed in public subnets
- **Security Group** allowing inbound HTTP/HTTPS traffic
- **Target Group** for routing traffic to EC2 instances
- **HTTP Listener** with redirection to HTTPS
- **HTTPS Listener** with a self-signed certificate
- **Elastic IP** attached to the ALB for stable addressing

### 3. EC2 Instance (modules/ec2)
- **EC2 Instance** in private subnet
- **Security Group** allowing traffic only from the ALB
- **SSH Key Pair** generated for instance creation
- **User Data** script to install and configure the web server
- **Target Group Attachments** to register instances with the ALB

## Design Principles and Best Practices

This implementation follows AWS and Terraform best practices:

1. **Security**:
   - Network segmentation with public/private subnets
   - Least privilege security groups (EC2 only accepts traffic from ALB)
   - HTTPS with SSL/TLS encryption
   - Private instances not directly accessible from the internet

2. **High Availability**:
   - Resources distributed across multiple availability zones
   - Load balancing for fault tolerance

3. **Modularity**:
   - Separate modules for VPC, ALB, and EC2 resources
   - Clear interfaces between modules with defined inputs/outputs
   - Reusable components that can be composed differently

4. **Maintainability**:
   - Consistent naming and tagging strategy
   - Variable-driven configuration for easier updates
   - Self-documented code with descriptive comments

5. **Scalability**:
   - Infrastructure designed to scale horizontally
   - Auto-discovery of latest AMIs
   - Target groups supporting multiple instances

## Resource List

The following AWS resources are created:

1. **Network Resources**:
   - 1 VPC
   - 2 Public Subnets
   - 2 Private Subnets
   - 1 Internet Gateway
   - 1 NAT Gateway
   - 2 Route Tables
   - 4 Route Table Associations
   - 1 Elastic IP (for NAT Gateway)

2. **Load Balancer Resources**:
   - 1 Application Load Balancer
   - 1 ALB Security Group
   - 1 Target Group
   - 1 HTTP Listener
   - 1 HTTPS Listener
   - 1 Self-signed SSL Certificate
   - 1 Elastic IP (for ALB)

3. **Compute Resources**:
   - 1+ EC2 Instances (configurable)
   - 1 EC2 Security Group
   - 1 Key Pair
   - Target Group Attachments (one per instance)

4. **Storage Resources**:
   - EBS Volumes (attached to EC2 instances)

## Getting Started

### Prerequisites
- Terraform v1.11.3 or later
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create the resources

### Deployment

**Note**: All the terrafrom commands must be run from the development Directory

1. Initialize Terraform 
   ```
   terraform init
   ```

2. Review the plan:
   ```
   terraform plan
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

4. After successful deployment, note the outputs for access information:
   - HTTPS URL for application access
   - SSH private key path and command for EC2 access

## Accessing the Infrastructure

After deploying the infrastructure:

1. **Web Application Access**:
   - Use the ALB DNS name output to access the web application (This will output in the terminal after the deploy is complete)
   - Access via HTTPS (you'll need to accept the self-signed certificate warning)

### Clean Up

```
terraform destroy
```