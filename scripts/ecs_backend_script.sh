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
sudo yum install -y nc
# Start and enable ECS agent
#sudo systemctl start ecs
sudo systemctl enable ecs

# Download the AWS CA bundle required for TLS connection to DocumentDB
sudo mkdir -p /etc/ssl/certs
sudo curl -fsSL -o /etc/ssl/certs/rds-combined-ca-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem


# Extract the hostname from the full MONGO_URI
# This command uses sed to pull out just the DNS name of the cluster endpoint

DOCDB_HOST=$(echo "${mongo_uri}" | sed -E 's#^mongodb://[^@]+@([^:]+):[0-9]+.*$#\1#')

echo "Checking connectivity to DocumentDB at $${DOCDB_HOST}:27017..."

# Loop until a successful TCP connection can be made to the DocumentDB host on port 27017
# -z: Zero-I/O mode (scanning)
# -v: Verbose
# -w3: Timeout after 3 seconds
until nc -z -v -w3 "$${DOCDB_HOST}" 27017; do
  echo "Waiting for DocumentDB to be available..."
  sleep 5
done

sudo reboot