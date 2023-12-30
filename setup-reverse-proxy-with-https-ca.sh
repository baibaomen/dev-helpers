#!/bin/bash

# 读取用户输入的环境变量，并验证非空
prompt_for_variable() {
  local input
  local variable_name=$1
  local prompt_message=$2
  while true; do
    read -e -p "$prompt_message: " input
    if [ -z "$input" ]; then
      echo "输入不能为空，请重新输入。"
    else
      eval $variable_name="'$input'"
      break
    fi
  done
}

# 读取用户输入的环境变量
prompt_for_variable DOMAIN "请输入DOMAIN"
prompt_for_variable PROXY_URL "请输入PROXY_URL"
prompt_for_variable CA_REALM "请输入CA_REALM"
prompt_for_variable CA_ADMIN "请输入CA_ADMIN"
prompt_for_variable CA_ADMIN_PASSWORD "请输入CA_ADMIN_PASSWORD"
prompt_for_variable EMAIL "请输入EMAIL"

# 安装Docker（如果尚未安装）
if ! command -v docker &> /dev/null
then
    echo "Docker未安装，正在安装..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# 替换DOMAIN中的点（.）为下划线（_），并构造容器名字
SANITIZED_DOMAIN=${DOMAIN//./_}
CONTAINER_NAME="webdecorator-$SANITIZED_DOMAIN"

# 运行Docker容器
sudo docker run --name $CONTAINER_NAME --restart always -d -p 80:80 -p 443:443 \
  -e DOMAIN=$DOMAIN \
  -e PROXY_URL=$PROXY_URL \
  -e CA_REALM=$CA_REALM \
  -e CA_ADMIN=$CA_ADMIN \
  -e CA_ADMIN_PASSWORD=$CA_ADMIN_PASSWORD \
  -e EMAIL=$EMAIL \
  baibaomen/webdecorator:latest

# 显示Docker容器的日志
sudo docker logs -f $CONTAINER_NAME
