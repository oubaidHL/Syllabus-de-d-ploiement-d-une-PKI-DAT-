# DAT Cyber Deployment

## Overview

This project contains:

* Your multi-service Docker app (DNS server, root & intermediate CAs, web server, etc.)
* Terraform scripts to provision a low-cost Azure VM with required networking
* Ansible playbook to install Docker, deploy the app, and run it on the VM
* A helper script (`deploy.sh`) to fully automate provisioning and deployment in one step

---

## Prerequisites

* Terraform installed and configured
* Ansible installed
* Azure CLI installed and logged in (`az login`)
* SSH key pair (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`) ready for VM access

---

## Deployment Steps

1. **Run the full automated deployment:**

```bash
./deploy.sh
```

This script will:

* Initialize and apply Terraform to provision the Azure VM
* Fetch the VM’s public IP address
* Run the Ansible playbook to install Docker and deploy your app on the VM

2. **Configure your local machine’s DNS**

Point your local domain to the VM’s public IP address to use your DNS server and access the web app.

3. **Access your web application**

Open your web browser and visit your domain via HTTPS (port 443).

---

## Notes

* The Azure VM has ports UDP 53, TCP 80, 443, 9000, and 9001 open to support your services.
* The project files are copied and launched automatically inside the VM.
* You can customize Terraform variables (location, VM size, admin username, SSH public key path) inside `/terraform/variables.tf`.

---

## Troubleshooting

* If you change the SSH key location, update the `ssh_public_key_path` variable in Terraform and the private key path in `deploy.sh` accordingly.
* For any Ansible connectivity issues, ensure your SSH key permissions are correct (`chmod 600 ~/.ssh/id_rsa`) and the VM is reachable.
* Use `terraform destroy` to clean up resources when no longer needed.

---

Happy deploying! 🚀

---