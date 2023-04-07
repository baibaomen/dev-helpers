# Dev-helpers

Dev-helpers is a collection of small but useful development and deployment helper files designed to save you time. Whether you're working on a small project or a large application, these helpers can simplify your workflow and make your development and deployment process more efficient.

## Install and configure Nginx with Certbot(Debian)

With just a single line of code, you can install and configure Git, Nginx, and Certbot on your Debian server, as well as automatically generate SSL certificates to secure your server.
At the end of the installation, input your domain name and email address, which are required by Certbot.

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

## Install Nodejs and pm2(Debian)
With just a single line of code, you can install Node.js 18.5 and PM2 on your Debian server. 
If you have other versions of Node.js installed, the command will remove the other version of Node.js and then install Node.js 18.5.

```
node_version=$(node -v); if [ -z "$node_version" ] || [ "${node_version:1:2}" != "18" ]; then sudo apt remove nodejs && sudo apt install -y snapd && sudo snap install node --classic --channel=18; export PATH="/snap/bin:$PATH"; fi && sudo apt install -y npm && sudo npm install pm2 -g
```

In the above command, the following steps will be performed automatically:

1. Check the installed Node.js version.
2. If Node.js version is not 18.x, remove the existing Node.js installation.
3. Install Snap package manager.
4. Install Node.js 18.5 using Snap.
5. Update the PATH variable to include Snap binaries.
6. Install NPM.
7. Install PM2 globally using NPM.
