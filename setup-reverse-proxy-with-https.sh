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

# Detecting OS and setting up variables for package management
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ $OS == *"Ubuntu"* ]]; then
    PKG_MANAGER="apt"
    PKG_UPDATE="apt update"
    PKG_INSTALL="apt install -y"
elif [[ $OS == *"CentOS"* ]]; then
    # CentOS 8 and above uses dnf, CentOS 7 and below uses yum
    if [[ $(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1) -ge 8 ]]; then
        PKG_MANAGER="dnf"
    else
        PKG_MANAGER="yum"
        # Enabling EPEL repository for CentOS 7 to install certbot
        sudo yum install -y epel-release
    fi
    PKG_UPDATE="$PKG_MANAGER makecache"
    PKG_INSTALL="$PKG_MANAGER install -y"
else
    echo "Unsupported OS"
    exit 1
fi

# Prompting user for domain name, proxy URL, host header, and email address with validation
domain=$(prompt_for_input "Enter the listening domain (e.g., ca-wechat.baibaomen.com): " "")
proxy_url=$(prompt_for_input "Enter the URL of the proxied site (e.g., http://127.0.0.1:8081): " "")
host_header=$(prompt_for_input "Enter the Host header value (e.g., example.com): " "")
email=$(prompt_for_input "Enter your email address for certbot (default: baibaomen@gmail.com): " "baibaomen@gmail.com")

# Checking if nginx is already installed
if ! which nginx > /dev/null 2>&1; then
    echo "Installing nginx..."
    sudo $PKG_UPDATE
    sudo $PKG_INSTALL nginx
else
    echo "nginx is already installed."
fi

# Checking if certbot is already installed
if ! which certbot > /dev/null 2>&1; then
    echo "Installing certbot..."
    if [[ $PKG_MANAGER == "apt" ]]; then
        sudo $PKG_INSTALL certbot python3-certbot-nginx
    else
        sudo $PKG_INSTALL certbot python3-certbot-nginx
    fi
else
    echo "certbot is already installed."
fi

# Creating nginx configuration file in conf.d
config_file="/etc/nginx/conf.d/$domain.conf"
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
        proxy_set_header Host $host_header;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        keepalive_timeout 600s;

        chunked_transfer_encoding off;
        proxy_cache off;
        proxy_buffering off;
        proxy_redirect off;
        proxy_ssl_server_name on;
        proxy_pass_request_headers on;
    }
}
EOF
else
    echo "Nginx configuration for $domain already exists."
fi

# No need to create a symlink, so we can reload nginx directly
sudo systemctl reload nginx

# Configuring SSL certificate with Certbot
sudo certbot --nginx -d $domain --non-interactive --agree-tos --email $email

# Completion message
echo "Setup completed successfully! Your Nginx server is now configured with SSL for $domain."
