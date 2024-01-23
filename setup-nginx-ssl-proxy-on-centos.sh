#!/bin/bash

# 脚本用途描述
echo "此脚本用于自动配置Nginx反向代理并为指定域名安装SSL证书。"
echo "请按照提示输入所需信息。"

# 检查是否以root权限运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本需要以root权限运行" 1>&2
   exit 1
fi

# 读取用户输入
echo "请输入域名（例如：ca.baibaomen.com）: "
read -e domain
echo "请输入目标站点地址（例如：http://oa.bbm.com:8080）: "
read -e target
echo "请输入您的电子邮件地址（默认：baibaomen@gmail.com）: "
read -e email
email=${email:-baibaomen@gmail.com}

# 检查并安装Nginx和Certbot
echo "检查Nginx和Certbot是否安装..."
if ! command -v nginx > /dev/null 2>&1; then
    echo "Nginx未安装，正在安装Nginx..."
    yum update && yum install -y nginx
fi

if ! command -v certbot > /dev/null 2>&1; then
    echo "Certbot未安装，正在安装Certbot..."
    yum install -y epel-release
    yum install -y certbot python2-certbot-nginx
fi

# 创建Nginx配置文件
config_file="/etc/nginx/conf.d/$domain.conf"

echo "创建Nginx配置文件：$config_file"

cat > $config_file <<EOF
server {
    server_name $domain;
    
    listen 80;
    listen [::]:80;
    
    location / {
        proxy_pass $target;
        proxy_redirect off;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        keepalive_timeout 600s;

        proxy_buffer_size   128k;
        proxy_buffers   4 256k;
        proxy_busy_buffers_size   256k;
    }
}
EOF

# 检查Nginx配置
if nginx -t; then
    echo "Nginx配置正确，正在重启Nginx..."
    systemctl restart nginx

    # 使用Certbot配置SSL证书
    echo "正在为 $domain 配置SSL证书..."
    certbot --nginx -d $domain --non-interactive --agree-tos -m $email

    echo "配置完成。"
else
    echo "Nginx配置错误，请检查配置文件。"
    exit 1
fi
