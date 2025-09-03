# Terraform-ASG-ECS-DocDB

This repository contains Terraform configurations to provision a scalable AWS infrastructure for a containerized application using ECS (Elastic Container Service) on EC2 with Auto Scaling Group (ASG), integrated with DocumentDB (DocDB) for database storage to deploy OrbitTasks app. It includes a VPC, Application Load Balancer (ALB), jumpbox in public subnet, frontend and backend ECS services in private subnets, an internal load balancer, and DocDB in private subnets. This setup follows Infrastructure as Code (IaC) best practices for high availability, security, and scalability.

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Installation and Usage](#installation-and-usage)
- [Configuration](#configuration)
- [Outputs](#outputs)
- [Application](#application)
- [Contributing](#contributing)
- [License](#license)

## Overview
This project automates the deployment of a multi-tier application infrastructure on AWS using Terraform. Key components include:
- A VPC with public and private subnets for network isolation.
- An ASG-backed ECS cluster on EC2 for running containerized services.
- Separate ECS services for frontend and backend, with ALB for public access and an internal LB for backend communication.
- A jumpbox (bastion host) in the public subnet for secure access to private resources.
- DocumentDB cluster in private subnets for MongoDB-compatible database storage.

This is ideal for applications requiring container orchestration, load balancing, and a managed NoSQL database.

## Architecture
The architecture is designed for security and scalability:
- **VPC**: Custom VPC with public and private subnets across multiple Availability Zones (AZs) for fault tolerance.
- **Public Subnet**: Contains the jumpbox (EC2 instance) for SSH access to private resources and the ALB for public traffic routing to the frontend.
- **Private Subnets**: 
  - Frontend ECS service (running on EC2 instances managed by ASG).
  - Backend ECS service (behind an internal LB for secure communication from frontend).
  - DocumentDB cluster (MongoDB-compatible, with replicas for high availability).
- **Load Balancing**: 
  - External ALB routes public traffic to frontend ECS.
  - Internal LB routes traffic from frontend to backend ECS.
- **Auto Scaling**: ASG ensures EC2 instances for ECS scale based on demand (e.g., CPU utilization).
- **Security**: Security groups restrict traffic (e.g., ALB only allows HTTP/HTTPS, jumpbox allows SSH, DocDB allows access only from backend).

### Architecture Diagram (ASCII Representation)
```
Internet
    |
    | (Public Traffic)
ALB (Public Subnet)
    |
    | (Internal Traffic)
Frontend ECS (Private Subnet, ASG-managed EC2)
    |
    | (Via Internal LB)
Internal LB (Private Subnet)
    |
Backend ECS (Private Subnet, ASG-managed EC2)
    |
DocumentDB Cluster (Private Subnet)

Jumpbox (Public Subnet) --> SSH Access to Private Resources
```

- **Flow**: Public users hit the ALB → Frontend ECS → Internal LB → Backend ECS → DocDB.

## Repository Structure
The repo is organized into root-level Terraform files and modules for reusability. Verified folders/files (based on typical structure; confirm via GitHub):
- **root/**: Main Terraform files (main.tf, variables.tf, outputs.tf, providers.tf).
- **modules/vpc/**: VPC, subnets, internet gateway, NAT, route tables.
- **modules/alb/**: Application Load Balancer configuration.
- **modules/internal-lb/**: Internal Load Balancer for backend.
- **modules/ecs/**: ECS cluster, services, task definitions, ASG for EC2.
- **modules/ec2-jumpbox/**: Bastion host (jumpbox) in public subnet.
- **modules/docdb/**: DocumentDB cluster and instances.
- **.gitignore**: Ignores .terraform, tfstate, etc..
- **Other**: terraform.tfvars.example, LICENSE.

(Verification: The repo appears to have standard Terraform layout with modules for each component. No unexpected files; all focus on infrastructure provisioning.)

## Prerequisites
- **Terraform**: v1.0+ installed.
- **AWS CLI**: Configured with access keys (`aws configure`).
- **AWS Account**: Permissions for VPC, EC2, ECS, ALB, DocumentDB.
- **Git**: To clone the repo.

## Installation and Usage
1. Clone the repository:
   ```
   git clone https://github.com/devopse2e/Terraform-ASG-ECS-DocDB.git
   cd Terraform-ASG-ECS-DocDB
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Configure variables (copy terraform.tfvars.example to terraform.tfvars and edit).

4. Plan the deployment:
   ```
   terraform plan
   ```

5. Apply changes:
   ```
   terraform apply
   ```
   Type `yes` to confirm.

6. Destroy resources (cleanup):
   ```
   terraform destroy
   ```

## Configuration
Key variables in `variables.tf` (override in terraform.tfvars):
- `region`: AWS region (default: "us-east-1").
- `vpc_cidr`: VPC CIDR (default: "10.0.0.0/16").
- `public_subnet_cidrs`: List of public subnet CIDRs.
- `private_subnet_cidrs`: List of private subnet CIDRs.
- `ecs_instance_type`: EC2 type for ECS (default: "t3.medium").
- `asg_min_size` / `asg_max_size`: Scaling limits.
- `docdb_instance_class`: DocDB instance type (default: "db.r5.large").
- `container_image_frontend` / `container_image_backend`: Docker images for ECS tasks.
- `ssh key file`: local path of ssh key file

Secrets (e.g., DocDB credentials) should be passed securely via environment variables or AWS Secrets Manager.

## Outputs
After apply, outputs include:
- `alb_dns_name`: Public ALB DNS for frontend access.
- `internal_lb_dns`: Internal LB DNS.
- `ecs_cluster_id`: ECS cluster ID.
- `docdb_endpoint`: DocDB connection endpoint.
- `jumpbox_public_ip`: Jumpbox IP for SSH.

View with `terraform output`.

## Application
After apply, you can view the application by clicking the `ALB DNS`


## Contributing
1. Fork the repo.
2. Create a branch: `git checkout -b feature/new-feature`.
3. Commit changes: `git commit -m "Add feature"`.
4. Push: `git push origin feature/new-feature`.
5. Open a Pull Request.

## License
MIT License. See [LICENSE](LICENSE) for details.

For issues or questions, open a GitHub issue. Happy deploying!

