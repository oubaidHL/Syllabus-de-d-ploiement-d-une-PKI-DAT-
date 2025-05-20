# DAT Cyber Deployment

## Overview

This project provides a complete automated deployment for a multi-service PKI system including:

* **DNS server**,
* **Root and Intermediate Certificate Authorities (CAs)**,
* **Web server**,
* And supporting services.

It uses:

* **Terraform** to provision a low-cost Azure VM with necessary networking.
* **Ansible** to install Docker, Docker Compose, Git, and deploy the project containers on the VM.
* **A helper script (`deploy.sh`)** to automate the entire process from infrastructure provisioning to app deployment.

---

## Directory Structure

```plaintext
.
├── ansible
│   ├── inventory.ini
│   ├── inventory.ini.bak
│   ├── playbook.yml
│   └── roles
│       ├── deploy_project
│       │   └── tasks/main.yml
│       └── tools_install
│           └── tasks/main.yml
├── app
│   ├── ca-intermediate/
│   ├── dns-server/
│   ├── docker-compose.yaml
│   ├── nat-masquerade/
│   ├── root-ca/
│   └── web-server/
├── deploy.sh
├── README.md
└── terraform
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

---

## Prerequisites

* **Terraform** installed and configured
* **Ansible** installed
* **Azure CLI** installed and logged in (`az login`)
* **SSH key pair** (default path `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`) for VM access

---

## Usage Instructions

### For Unix/Linux Users (Kali, Ubuntu, etc.)

You can run the full deployment with the helper script:

```bash
./deploy.sh
```

This script will:

* Automatically generate an SSH key if none exists (`~/.ssh/id_rsa_terraform` by default).
* Provision the Azure VM with Terraform.
* Fetch the VM’s public IP address.
* Run the Ansible playbook to install Docker, Docker Compose, Git, and deploy the app.
* Or destroy all the infra :) .

---

### For Windows Users

* The easiest way to run the deployment script is via **Windows Subsystem for Linux (WSL)** which allows running Linux commands and scripts.
* Alternatively, you can manually run Terraform and Ansible using Windows tools but this requires additional configuration.

---

## Manual Deployment Instructions

If you prefer to deploy manually or troubleshoot, follow these steps:

### Terraform

1. Go to the Terraform directory:

   ```bash
   cd terraform
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Validate configuration:

   ```bash
   terraform validate
   ```

4. See planned changes:

   ```bash
   terraform plan
   ```

5. Apply to provision resources:

   ```bash
   terraform apply
   ```

6. To destroy resources later:

   ```bash
   terraform destroy
   ```

---

### Docker and App Deployment on the VM

1. SSH into your VM (replace with actual IP):

   ```bash
   ssh -i ~/.ssh/id_rsa_terraform azureuser@<VM_PUBLIC_IP>
   ```

2. Install Docker, Docker Compose, and Git if needed (see [Docker official install instructions](https://docs.docker.com/engine/install/ubuntu/)).

3. Clone the project repository (if not already cloned):

   ```bash
   git clone https://github.com/oubaidHL/Syllabus-de-d-ploiement-d-une-PKI-DAT-.git
   cd Syllabus-de-d-ploiement-d-une-PKI-DAT-
   ```

4. Go into the app folder:

   ```bash
   cd app
   ```

5. Run Docker Compose:

   ```bash
   docker compose up -d
   ```

---

## Configuration

* Update the **Terraform variables** (`terraform/variables.tf`) to set your desired:

  * Azure subscription ID
  * Location
  * VM size
  * Admin username
  * SSH public key path

* Update the **SSH key path** in `deploy.sh` if you want to use a custom key.

---

## Notes

* The Azure VM has ports UDP 53, TCP 80, 443, 9000, and 9001 open only to support this custom demo.
---> For production or other use cases, it's best practice to configure your own VPN and customize port settings accordingly, **be cautious with exposing these ports.**
* The `deploy.sh` script fully automates the deployment process for Unix-like environments.
* If the SSH key does not exist, it will be generated automatically.
* Windows users are encouraged to use WSL or deploy manually.
* Use `terraform destroy` to clean up resources after use.

---

## Troubleshooting

* Ensure SSH key permissions are correct (`chmod 600 ~/.ssh/id_rsa_terraform`).
* Confirm that the VM is reachable via SSH and the correct public IP is used.
* Check Docker service status on the VM (`sudo systemctl status docker`).
* If DNS or services are not reachable, verify firewall and security group settings on Azure.

---

## License

Feel free to modify and adapt this project as needed.

---

## Happy Deploying! 🚀

---