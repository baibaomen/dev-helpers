#!/bin/bash

# Initialize parameters as empty
domain=""
email=""

# Use getopts to handle named arguments
while getopts ":d:e:" opt; do
  case $opt in
    d)
      domain="$OPTARG"
      ;;
    e)
      email="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check if command-line arguments are provided
if [ -z "$domain" ]; then
    # Get user input for the domain
    echo "Please enter your domain (e.g., welogin.baibaomen.com):"
    read domain
fi

if [ -z "$email" ]; then
    # Get user input for the email address
    echo "Please enter your email address (e.g., your-email@example.com):"
    read email
fi

# Install Nginx
sudo apt update
sudo apt install -y nginx

# Set up Nginx configuration
sudo tee /etc/nginx/sites-available/$domain > /dev/null << EOF
server {
    listen 80;
    server_name $domain;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;

    location / {
        root /var/www/html;
        index index.html;
    }
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain the certificate (using --deploy-hook to automatically update Nginx configuration)
sudo certbot --nginx -d $domain --redirect --non-interactive --agree-tos --email $email --deploy-hook 'systemctl reload nginx'

# Set up automatic certificate renewal
sudo systemctl enable --now certbot.timer
