#!/usr/bin/env bash

echo "BOOTSRAPPING SYSTEM FOR HOMEAI"
echo "NOTE: This ecosystem is intended to be installed on a Debian 12 System \
functionality is not promised on a system of any other type!"

echo "Upgrading packages..."
apt update && apt upgrade -y

echo "Installing dependencies..."
apt install ansible git -y

echo "DEPENDENCIES INSTALLED!"
sleep 2

echo "Cloning HomeAI Project..."
git clone https://github.com/VOID1793/HomeAI

echo "Executing bootstrapping playbooks..."
ansible-playbook ./HomeAI/ansibleBootstrap/bootstrapper.yml

