#!/bin/bash

# Update system
sudo yum update -y

# Clean any existing Docker/ECS state (prevents conflicts)
sudo systemctl stop ecs || true  # Ignore if not running
sudo yum remove ecs-init -y || true
sudo rm -rf /var/lib/ecs /var/log/ecs
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine -y || true


# Install Docker
sudo yum install docker -y

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
sudo usermod -a -G docker ec2-user


# Configure ECS to join your cluster (matches your module's cluster name)
sudo mkdir -p /etc/ecs
sudo sh -c 'echo "ECS_CLUSTER=${name_prefix}-ecs-cluster" > /etc/ecs/ecs.config'

# Enable AWS logging (optional but recommended)
sudo sh -c 'echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"awslogs\"]" >> /etc/ecs/ecs.config'

# Install ECS agent
sudo yum install -y ecs-init

# Start and enable ECS agent
#sudo systemctl start ecs
sudo systemctl enable ecs


sudo reboot