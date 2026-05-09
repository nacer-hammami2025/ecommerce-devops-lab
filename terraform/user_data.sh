#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install Python (required for Ansible)
apt-get install -y python3 python3-pip

# Install Docker
apt-get install -y docker.io docker-compose

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install PM2
npm install -g pm2

# Create app directory
mkdir -p /opt/ecommerce
cd /opt/ecommerce

# Create docker-compose.yml placeholder (will be created by Ansible)
cat > docker-compose.yml << EOF
version: '3.8'

services:
  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./html:/usr/share/nginx/html:ro
    restart: always

  app:
    image: node:18-alpine
    container_name: app
    working_dir: /app
    volumes:
      - ./app:/app
    ports:
      - "3000:3000"
    restart: always

  mongodb:
    image: mongo:5.0
    container_name: mongodb
    ports:
      - "27017:27017"
    restart: always

EOF

echo "User data script completed"
