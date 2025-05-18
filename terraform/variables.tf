variable "location" {
  default = "eastus"
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_username" {
  default = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key to use for VM login"
  default     = "~/.ssh/id_rsa.pub"
}
