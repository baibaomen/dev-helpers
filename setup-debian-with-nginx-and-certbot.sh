#!/bin/bash

# Install Nginx
sudo apt update
sudo apt install -y nginx

# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

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

# Set up Nginx configuration
sudo tee /etc/nginx/sites-available/$domain > /dev/null << EOF
server {
    listen 80;
    server_name $domain;
    location / {
        root /var/www/html;
        index index.html;
    }
}
EOF

# Create the default Nginx welcome page if it doesn't exist
sudo mkdir -p /var/www/html
if [ ! -f /var/www/html/index.html ]; then
    sudo tee /var/www/html/index.html > /dev/null << EOF
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>

<h1>Welcome to nginx!</h1><p>If you see this page, the Nginx web server with SSL certificate auto-renewal has been successfully installed and is working. Additional configuration may be required.</p>
<p>The automated installation process is powered by <a href="https://github.com/baibaomen/dev-helpers">https://github.com/baibaomen/dev-helpers</a>.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
EOF
fi

# Enable site
sudo ln -sf /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Obtain the certificate and update Nginx configuration (using --deploy-hook to automatically update Nginx configuration)
sudo certbot --nginx -d $domain --redirect --non-interactive --agree-tos --email $email --deploy-hook 'systemctl reload nginx'

# Set up automatic certificate renewal
sudo systemctl enable --now certbot.timer
