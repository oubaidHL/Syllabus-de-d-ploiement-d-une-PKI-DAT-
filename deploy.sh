#!/bin/bash
set -e

# Define directory variables
ANSIBLE_DIR="./ansible"
TERRAFORM_DIR="./terraform"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"
KEY_NAME="$HOME/.ssh/id_rsa_terraform"

# Ask the user whether to deploy or destroy
echo "Choose action:"
echo "1. Deploy"
echo "2. Destroy"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "2" ]; then
  echo "Destroying the infrastructure..."

  # Navigate to the Terraform directory
  cd "$TERRAFORM_DIR"

  # Run Terraform destroy
  terraform init
  terraform destroy -auto-approve

  echo "Infrastructure destroyed."
  exit 0
fi

if [ "$choice" != "1" ]; then
  echo "Invalid option. Exiting."
  exit 1
fi

echo "Starting full deployment..."

# Check if SSH key exists; if not, generate it
if [ ! -f "${KEY_NAME}" ]; then
  echo "SSH key ${KEY_NAME} not found. Generating new keypair..."
  ssh-keygen -t rsa -b 4096 -f "${KEY_NAME}" -N "" -q
  echo "SSH key generated at ${KEY_NAME} and ${KEY_NAME}.pub"
else
  echo "SSH key ${KEY_NAME} already exists. Using existing key."
fi

# Run Terraform in the terraform directory
cd "$TERRAFORM_DIR"
terraform init
terraform apply -auto-approve

# Wait until the VM public IP is available
echo "Waiting for VM public IP to be assigned..."

VM_IP=$(terraform output -raw vm_public_ip 2>/dev/null || echo "")

MAX_RETRIES=24
count=0

while [ -z "$VM_IP" ] && [ $count -lt $MAX_RETRIES ]; do
  sleep 5
  terraform refresh
  VM_IP=$(terraform output -raw vm_public_ip 2>/dev/null || echo "")
  count=$((count+1))
done

if [ -z "$VM_IP" ]; then
  echo "Error: VM public IP was not assigned within timeout." >&2
  exit 1
fi

echo "Azure VM public IP: $VM_IP"

# Return to project root directory
cd ..

# Ensure ansible directory exists
mkdir -p "$ANSIBLE_DIR"

# Prepare the new inventory line with the correct IP and options
NEW_LINE="$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=$KEY_NAME ansible_python_interpreter=/usr/bin/python3"

# Create or update the inventory file
if [ ! -f "$INVENTORY_FILE" ]; then
  echo "[azure_vm]" > "$INVENTORY_FILE"
  echo "$NEW_LINE" >> "$INVENTORY_FILE"
  echo "Created new Ansible inventory at $INVENTORY_FILE"
else
  if grep -qE "^\s*${VM_IP//./\\.}" "$INVENTORY_FILE"; then
    echo "VM IP already in inventory, no change needed."
  else
    cp "$INVENTORY_FILE" "$INVENTORY_FILE.bak"
    awk -v new_line="$NEW_LINE" '
      BEGIN {in_group=0}
      /^\[azure_vm\]/ {
        print
        in_group=1
        print new_line
        next
      }
      /^\[/ {
        if (in_group) in_group=0
        print
        next
      }
      {
        if (!in_group) print
      }
    ' "$INVENTORY_FILE.bak" > "$INVENTORY_FILE.tmp"
    mv "$INVENTORY_FILE.tmp" "$INVENTORY_FILE"
    echo "Updated VM IP in Ansible inventory."
  fi
fi

# Disable host key checking for Ansible runs to avoid SSH verification issues
echo "Running Ansible playbook..."
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "$INVENTORY_FILE" "$ANSIBLE_DIR/playbook.yml"

echo "Deployment complete."
echo "You can now configure your host DNS to use ${VM_IP} for your domain."
echo "To SSH into your VM, run:"
echo "ssh -i ${KEY_NAME} azureuser@${VM_IP}"
