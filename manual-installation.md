# Instalação manual

##### DOC OFICIAL: https://docs.graylog.org/docs/ubuntu

### Pré requisitos

```bash
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen
```

### Instalando o MongoDB

```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
```

### Iniciar e Habilitar o MongoDB na inicialização do sistema

```bash
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl restart mongod.service
sudo systemctl --type=service --state=active | grep mongod
```

### Instalando o Elasticsearch 7.x

```bash
wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch -O myKey
sudo apt-key add myKey
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install elasticsearch-oss
```

### Adicione esta configuração no Elasticsearch

```bash
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT
```

### Iniciar e Habilitar o Elasticsearch na inicialização do sistema

```bash
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
sudo systemctl --type=service --state=active | grep elasticsearch
```

### Verifique se o elastic search foi cofigurado corretamente

```bash
curl -XGET 'http://localhost:9200'
```

Se o comando acima retornar estas informações, então está tudo certo!

```json
{
  "name": "ubuntu1804.localdomain",
  "cluster_name": "graylog",
  "cluster_uuid": "n7g5JrXXR4yRegsGerUoSw",
  "version": {
    "number": "7.10.2",
    "build_flavor": "oss",
    "build_type": "deb",
    "build_hash": "747e1cc71def077253878a59143c1f785afa92b9",
    "build_date": "2021-01-13T00:42:12.435326Z",
    "build_snapshot": false,
    "lucene_version": "8.7.0",
    "minimum_wire_compatibility_version": "6.8.0",
    "minimum_index_compatibility_version": "6.0.0-beta1"
  },
  "tagline": "You Know, for Search"
}
```

### Instalação do graylog

```bash
wget https://packages.graylog2.org/repo/packages/graylog-4.2-repository_latest.deb
sudo dpkg -i graylog-4.2-repository_latest.deb
sudo apt-get update && sudo apt-get install graylog-server graylog-enterprise-plugins graylog-integrations-plugins graylog-enterprise-integrations-plugins
```

### Gere o password secret

```bash
pwgen -s 96 1
```

Exemplo de saída esperada

```bash
3bkbOFRi0pPewI2K8ctk6S98lwKMRrvimXNzYnLykfN2SZW6qFFzWhX0gNLhwQp6TA7PnircDSjhHOFA1Gdjnt6HCsLIwyvN
```

### Gere o root_password_sha2

**ATENÇÃO:** Esta é a senha que você irá utilizar para logar na interface web.

```bash
echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1
```

Exemplo de saída esperada após digitar a senha.

```bash
80f245e39125cfe234acf9cdda4a61d7f749244a4d2051642daf179a9b30f690
```

### Configure o graylog server

Procure e atualize esses campos em `/etc/graylog/server/server.conf`

```conf
password_secret = Hash gerado pelo comando pwgen
root_password_sha2 = Hash gerado pelo comando echo
http_bind_address = 0.0.0.0:9000
http_publish_uri = http://IP-DA-MAQUINA:9000
root_timezone = America/Sao_Paulo
```

### Iniciar e habilitar o graylog na inicialização do sistema

```bash
sudo systemctl daemon-reload
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service
sudo systemctl --type=service --state=active | grep graylog
```

A partir daqui o graylog já deverá estar funcionando corretamente.
