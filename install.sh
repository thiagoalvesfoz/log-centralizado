#!/bin/bash

BLUE='\e[34m'

echo -e "${BLUE}######################################################################################################"
echo -e "${BLUE} INSTALL DEPENDENCIES"
echo -e "${BLUE}######################################################################################################"

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen -y

echo -e "${BLUE}######################################################################################################"
echo -e "${BLUE} INSTALL MONGODB"
echo -e "${BLUE}######################################################################################################"

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# INICIAR E HABILITAR MONGODB NA INICIALIZAÇÃO DO SISTEMA
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl restart mongod.service
sudo systemctl --type=service --state=active | grep mongod

echo -e "${BLUE}######################################################################################################"
echo -e "${BLUE} INSTALL ELASTICSEARCH 7.*"
echo -e "${BLUE}######################################################################################################"

wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch -O myKey
sudo apt-key add myKey
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install elasticsearch-oss

# MODIFICAR CONFIGURAÇÕES
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT

# INICIAR E HABILITAR ELASTICSEARCH NA INICIALIZAÇÃO DO SISTEMA
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
sudo systemctl --type=service --state=active | grep elasticsearch

# VERIFICAR SE O ELASTICSEARCH ESTÁ FUNCIONANDO
curl -XGET 'http://localhost:9200'

echo -e "${BLUE}######################################################################################################"
echo -e "${BLUE} INSTALL GRAYLOG"
echo -e "${BLUE}######################################################################################################"

wget https://packages.graylog2.org/repo/packages/graylog-4.2-repository_latest.deb
sudo dpkg -i graylog-4.2-repository_latest.deb
sudo apt-get update && sudo apt-get install graylog-server graylog-enterprise-plugins graylog-integrations-plugins graylog-enterprise-integrations-plugins -y

# GET IP HOST
IP_HOST=$(ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# OBTER PASSWORD SECRET
PASSWORD_SECRET=$(pwgen -s 96 1)

# OBTER ROOT PASSWORD
ROOT_PASSWORD_SHA2=$(echo -n $1 | sha256sum | cut -d" " -f1)

# EDITAR CONFIGURAÇÕES DO SERVER GRAYLOG
sudo tee -a /tmp/graylog/server.conf > /dev/null <<EOT
password_secret = $PASSWORD_SECRET
root_password_sha2 = $ROOT_PASSWORD_SHA2
http_bind_address = 0.0.0.0:9000
http_publish_uri = http://$IP_HOST:9000
root_timezone = America/Sao_Paulo
EOT

# ADICIONAR PERMISSÃO
sudo chmod 644 /tmp/graylog/server.conf
sudo chown root:root /tmp/graylog/server.conf

# ATUALIZAR CONFIGURAÇÕES DO GRAYLOG
sudo rm /etc/graylog/server/server.conf
sudo mv /tmp/graylog/*.conf /etc/graylog/server/server.conf

# INICIAR E HABILITAR GRAYLOG NA INICIALIZAÇÃO DO SISTEMA
sudo systemctl daemon-reload
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service
sudo systemctl --type=service --state=active | grep graylog