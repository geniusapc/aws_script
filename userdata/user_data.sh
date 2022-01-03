#!/bin/bash
USERDIR="/home/ubuntu"

apt -y update
apt -y upgrade


apt install -y nginx
curl -sL https://deb.nodesource.com/setup_12.x |  bash -
apt install -y nodejs
apt install build-essential
apt install -y npm
npm install -g npm@latest
npm install -g pm2


apt install -y awscli
apt install -y jq
apt install -y mysql-client

# aws codedeploy user agent
apt install -y ruby
apt install -y wget
cd ${USERDIR}
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto


# firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw enable


cat << EOF > "/etc/nginx/sites-available/site.example.com"
server{
  listen 80;
  listen [::]:80;
  server_name site.example.com;

  access_log /var/log/nginx/access-site.example.com.log;
  error_log /var/log/nginx/error-site.example.com.log;
  
  location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade "\$http_upgrade";
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host "\$host";
        proxy_cache_bypass "\$http_upgrade";
  }
}
EOF

# deny access to ip address
cat << EOF > "/etc/nginx/sites-available/default"
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    deny all;
}
EOF

ln -s "/etc/nginx/sites-available/site.example.com"  "/etc/nginx/sites-enabled/site.example.com"

# turn off server token eg server version
sed -i 's/# server_tokens off;/server_tokens off;/' '/etc/nginx/nginx.conf'

nginx -t && nginx -s reload
systemctl enable nginx
