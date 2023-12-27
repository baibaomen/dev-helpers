#!/bin/bash

# Function to ensure non-empty input
prompt_for_input() {
    local input
    local prompt_message="$1"
    local default_value="$2"
    while true; do
        read -e -p "$prompt_message" input
        input="${input:-$default_value}"
        if [ -n "$input" ]; then
            echo "$input"
            break
        else
            echo "Input cannot be empty. Please enter a value."
        fi
    done
}

# Prompting user for necessary inputs
domain=$(prompt_for_input "Enter your domain (e.g., ca.baibaomen.com): " "")
keycloak_admin=$(prompt_for_input "Enter KeyCloak admin username: " "")
keycloak_admin_password=$(prompt_for_input "Enter KeyCloak admin password: " "")
email=$(prompt_for_input "Enter your email address for certbot (default: baibaomen@gmail.com): " "baibaomen@gmail.com")
internal_port=$(prompt_for_input "Enter the Docker internal port for KeyCloak (default: 8080): " "8080")

# Checking if Docker is installed
if ! which docker > /dev/null 2>&1; then
    echo "Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
else
    echo "Docker is already installed."
fi

# Container name based on domain
container_name="keycloak-${domain//./-}"

# Stopping and removing existing KeyCloak container
existing_container=$(sudo docker ps -aqf "name=${container_name}")
if [ -n "$existing_container" ]; then
    echo "Stopping and removing existing KeyCloak container named ${container_name}..."
    sudo docker stop $existing_container
    sudo docker rm $existing_container
fi

# Starting KeyCloak container
echo "Starting KeyCloak container named ${container_name}..."
sudo docker run -d -p ${internal_port}:8080 --name ${container_name} \
  -e KEYCLOAK_ADMIN=${keycloak_admin} \
  -e KEYCLOAK_ADMIN_PASSWORD=${keycloak_admin_password} \
  -e PROXY_ADDRESS_FORWARDING=true \
  -e REDIRECT_SOCKET=proxy-https \
  --restart always \
  quay.io/keycloak/keycloak:latest \
  start --hostname ${domain} --proxy=edge

# Checking if nginx is already installed
if ! which nginx > /dev/null 2>&1; then
    echo "Installing nginx..."
    sudo apt update
    sudo apt install -y nginx
else
    echo "nginx is already installed."
fi

# Checking if certbot is already installed
if ! which certbot > /dev/null 2>&1; then
    echo "Installing certbot..."
    sudo apt install -y certbot python3-certbot-nginx
else
    echo "certbot is already installed."
fi

# Define the proxy URL
proxy_url="http://localhost:${internal_port}"

# Removing existing nginx configuration if it exists
config_file="/etc/nginx/sites-available/$domain"
if [ -f "$config_file" ]; then
    echo "Removing existing nginx configuration for $domain..."
    sudo rm $config_file
    sudo rm /etc/nginx/sites-enabled/$domain
    sudo systemctl reload nginx
fi

# Creating new nginx configuration file
echo "Creating nginx configuration for $domain..."
cat <<EOF | sudo tee $config_file
server {
    server_name $domain;
    
    listen 80;
    listen [::]:80;
    
    location / {
        proxy_pass  $proxy_url;
        proxy_redirect                      off;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header  X-Real-IP         \$remote_addr;
        proxy_set_header  X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header  X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        keepalive_timeout 600s;
    }
}
EOF

# Enabling site and reloading nginx
sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
sudo systemctl reload nginx

# Configuring SSL certificate with Certbot
sudo certbot --nginx -d $domain --non-interactive --agree-tos --email $email

# Completion message
echo "KeyCloak installation with HTTPS reverse proxy completed successfully for ${domain}!"
