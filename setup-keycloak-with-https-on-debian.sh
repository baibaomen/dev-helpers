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
email=$(prompt_for_input "Enter your email address for certbot (default: baibaomen@gmail.com): " "baibaomen@gmail.com")
internal_port=$(prompt_for_input "Enter the Docker internal port for KeyCloak (default: 8080): " "8080")
keycloak_admin=$(prompt_for_input "Enter KeyCloak admin username: " "")
keycloak_admin_password=$(prompt_for_input "Enter KeyCloak admin password: " "")

# Checking if Docker is installed
if ! which docker > /dev/null 2>&1; then
    echo "Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
else
    echo "Docker is already installed."
fi

# Starting KeyCloak container
echo "Starting KeyCloak container..."
sudo docker run -d -p ${internal_port}:8080 \
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

# Creating nginx configuration file
config_file="/etc/nginx/sites-available/$domain"
if [ ! -f "$config_file" ]; then
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
else
    echo "Nginx configuration for $domain already exists."
fi

# Enabling site and reloading nginx
sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/ 2>/dev/null || echo "Site already enabled."
sudo systemctl reload nginx

# Configuring SSL certificate with Certbot
sudo certbot --nginx -d $domain --non-interactive --agree-tos --email $email

# Completion message
echo "KeyCloak installation with HTTPS reverse proxy completed successfully!"


