variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "username" {
  description = "User name used to access the server."
}

variable "password" {
  description = "Password used in conjunction with the username to access the server."
}

variable "private_ip_address_allocation" {
  description = "The allocation method used for the Private IP Address."
  validation {
    condition = anytrue([
      var.private_ip_address_allocation == "Dynamic",
      var.private_ip_address_allocation == "Static"
    ])
    error_message = "The private_ip_address_allocation value must be either 'Dynamic' or 'Static'."
  }
}

variable "vmsize" {
  description = "Provide a valid Azure VM size."
  default = "Standard_D2s_v3"
}

variable "total_vms" {
  description = "Provide a numeric value indicating how many VMs you want in the scale set. 2 is the default."
  default = 2
  type = number
}