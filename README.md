# Dev-helpers

Dev-helpers is a collection of small but useful development and deployment helper files designed to save you time. Whether you're working on a small project or a large application, these helpers can simplify your workflow and make your development and deployment process more efficient.

## Nginx with Certbot

You can install and configure Git, Nginx, and Certbot on your Debian server with just one line of code, and automatically generate SSL certificates to secure your server:
```
sudo apt update && sudo apt install -y git && rm -rf dev-helpers && sleep 1 && git clone https://github.com/baibaomen/dev-helpers.git && chmod +x dev-helpers/setup-debian-with-nginx-and-certbot.sh && ./dev-helpers/setup-debian-with-nginx-and-certbot.sh
```
In the above command, the following steps will be performed automatically:

1. Update the package list.
2. Install Git.
3. Clone the Dev-helpers repository.
4. Set the necessary permissions for the installation script.
5. Run the installation script to install and configure Nginx and Certbot.

Note that you should run the above command as a user with sudo privileges.
