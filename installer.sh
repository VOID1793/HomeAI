#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee -a /var/log/homeai_bootstrap.log) 2>&1

apt-get install sudo -y

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root (e.g., sudo -s)"; exit 1
fi

echo "BOOTSRAPPING SYSTEM FOR HOMEAI"
echo "NOTE: This ecosystem is intended to be installed on a Debian System \
functionality is not promised on a system of any other type!"


echo "Setting up service account..."
if ! id "ai-overlord" &>/dev/null; then
    echo "AI service account is missing! Creating now..."
    groupadd -g 10010 ai-overlord
    useradd -m -u 10010 -g ai-overlord -s /bin/bash ai-overlord
    echo "ai-overlord created with UID = 10010 and GID = 10010"
else
    echo "Service account already exists!"
fi

echo "Upgrading packages..."
apt-get update && apt-get upgrade -y

echo "Installing dependencies..."
apt-get install ansible git -y

echo "DEPENDENCIES INSTALLED!"
sleep 2

echo "Cloning HomeAI Project..."
sudo -u ai-overlord -H bash -lc 'cd ~ && git clone https://github.com/VOID1793/HomeAI || (cd ~/HomeAI && git pull --ff-only)'

echo "Executing bootstrapping playbook..."
ansible-playbook /home/ai-overlord/HomeAI/ansibleBootstrap/bootstrapper.yml


if id -nG ai-overlord | tr ' ' '\n' | grep -qx docker; then
  echo "ai-overlord is already in the docker group."
else
  usermod -aG docker ai-overlord
  echo "Added ai-overlord to the docker group."
fi


echo "Creating project directories in /opt..."

install -d -o 10010 -g 10010 -m 0755  /opt/HomeAI/models
install -d -o 10010 -g 10010 -m 0755  /opt/HomeAI/openwebui_data
install -d -o 10010 -g 101 -m 0755  /opt/HomeAI/NGINX/etc/nginx/conf.d
install -d -o root -g 101 -m 740 /opt/HomeAI/CERTBOT/etc/letsencrypt
install -d -o 10010 -g 101 -m 0755  /opt/HomeAI/CERTBOT/var/www/certbot
install -d -o root -g root -m 700 /opt/HomeAI/CERTBOT/.cfcreds

touch /opt/HomeAI/CERTBOT/.cfcreds/cloudflare.ini
chmod 600 /opt/HomeAI/CERTBOT/.cfcreds/cloudflare.ini

echo "Paste your Cloudflare API token: "
read -s TOKEN
printf("\n")
echo "dns_cloudflare_api_token = ${TOKEN}" > /opt/HomeAI/CERTBOT/.cfcreds/cloudflare.ini
TOKEN=""

echo "Setting NGINX Configuration... "
sudo -u ai-overlord -H bash -lc 'cp ~/HomeAI/conf/ai-overlord.conf /opt/HomeAI/NGINX/etc/nginx/conf.d'

echo "Injecting daily NGINX reload cron job... "
echo "0 3 * * * root docker exec nginx nginx -s reload" > /etc/cron.d/nginx-reload
chmod 644 /etc/cron.d/nginx-reload

echo "Bringing up the stack! "
sudo -u ai-overlord -H bash -lc 'cd ~/HomeAI && docker compose up -d'

sudo docker ps
