#!/bin/bash
set -e

echo "Starting full deployment..."

cd terraform
terraform init
terraform apply -auto-approve

VM_IP=$(terraform output -raw vm_public_ip)
echo "Azure VM public IP: $VM_IP"

cd ../ansible

echo "Running Ansible playbook..."
ansible-playbook -i "${VM_IP}," playbook.yml -u azureuser --private-key ~/.ssh/id_rsa

echo "Deployment complete."
echo "You can now configure your host DNS to use ${VM_IP} for your domain."
