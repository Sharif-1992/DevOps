variable "log_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "my-log-workspace"
}

variable "log_workspace_sku" {
  description = "SKU for the Log Analytics Workspace (PerGB2018 or CapacityReservation or Free)"
  type        = string
  default     = "PerGB2018"
}

variable "log_workspace_retention" {
  description = "Data retention in days for the Log Analytics Workspace"
  type        = number
  default     = 30
}

variable "vm_name" {
  description = "Name of the VM to create"
  type        = string
  default     = "demo-vm"
}

variable "vm_admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8iJROBY+EoDDTno9q+saU8Bgyr2j9HoXWDfJpmrKIY5EDEo0isncANBcAp9Lv7uzW3ARVpdsJwwrAfQ9sFD6Jq+eydQPsxxn4dWOYZsOjlGa87H1wYllGapxMzjZJ/8+2Vrs0FH+NKqJKA9Oy/mAgSpGQvRuv8UsyWobUpalVrJd6uj35K2YeTQEr8gZxOzJl33rqvEvFM2sG3RkQQq4HTZuj5Bqg9UTNcbFNyTUJ1NTMBLh1KX2ZzO9VjsBUvdABwSEOFKXpgBwxjYehL4LkKFyvQuLs3tFIUiLrXzIVouip8/fmaNm5TckSvwt2shVCtmV+cHXQG0KEHhyTAHeVSiyDOeTylSQ5vUtYtuJoCbNsep2MCwqmMHkfkaS+kUvlIBPk86no8BGrW+jrtwxp82H1uXF233DDXqfeJTXWu3XiBd0kSItNnXdOcGPks/x5YTu1pN8cJo/YceX6BWu6LynY/kR0Q7/3av4kBIQebPfL3jPNLuK3UZ6zrYUYunk= generated-by-azure"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1s"
}
