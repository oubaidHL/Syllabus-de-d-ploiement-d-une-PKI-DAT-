variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "a6419663-4f24-4b13-a11f-8eb7ddeba8d8"
}
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
  default     = "~/.ssh/id_rsa_terraform.pub"
}
