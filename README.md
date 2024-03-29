# Dev-helpers

Dev-helpers is a collection of small but useful development and deployment helper files designed to save you time. Whether you're working on a small project or a large application, these helpers can simplify your workflow and make your development and deployment process more efficient.

## Install and configure Nginx with Certbot(Debian)

With just a single line of code, you can install and configure Git, Nginx, and Certbot on your Debian server, as well as automatically generate SSL certificates to secure your server.
At the end of the installation, input your domain name and email address, which are required by Certbot.

```
sudo apt update && sudo apt install -y git && rm -rf dev-helpers && sleep 1 && git clone https://github.com/baibaomen/dev-helpers.git && chmod +x dev-helpers/setup-reverse-proxy-on-debian.sh && ./dev-helpers/setup-reverse-proxy-on-debian.sh
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


## Display project structure(Windows)
When pair programming with ChatGPT, you may need to display the current project structure. 
The list-files.bat can traverse directories and generate a list of effective files in the directory structure, while excluding those listed in the .gitignore file.


## Setup KeyCloak with certbot(Debian)
```
sudo apt update && sudo apt install -y git && rm -rf dev-helpers && sleep 1 && git clone https://github.com/baibaomen/dev-helpers.git && chmod +x dev-helpers/setup-keycloak-with-https-on-debian.sh && ./dev-helpers/setup-keycloak-with-https-on-debian.sh
```
Or in China, you can use githubfast.com:

```
sudo apt update && sudo apt install -y git && rm -rf dev-helpers && sleep 1 && git clone https://githubfast.com/baibaomen/dev-helpers.git && chmod +x dev-helpers/setup-keycloak-with-https-on-debian.sh && ./dev-helpers/setup-keycloak-with-https-on-debian.sh
```

