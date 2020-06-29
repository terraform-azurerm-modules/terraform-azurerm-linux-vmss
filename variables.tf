variable "name" {
  description = "Name for a single VM. Use 'names' for multiple VMs. "
  type        = string
  default     = ""
}

variable "instances" {
  description = "Number of VMs in the scale set."
  type        = number
  default     = 2
}

variable "proximity_placement_group_id" {
  description = "Resource ID for proximity placement group if ensuring low latency."
  type        = string
  default     = null
}

variable "source_image_id" {
  description = "Custom virtual image ID. Use either this or specify the source image_reference for platform images."
  type        = string
}

variable "source_image_reference" {
  // Not currently used - custom images only
  description = "Standard image reference block for platform images. Do not use if specifying a custom source_image_id."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null

}

// ==============================================================================

variable "defaults" {
  description = "Collection of user configurable default values."
  type = object({
    resource_group_name  = string
    location             = string
    tags                 = map(string)
    vm_size              = string
    storage_account_type = string
    admin_username       = string
    admin_ssh_public_key = string
    additional_ssh_keys = list(object({
      username   = string
      public_key = string
    }))
    subnet_id            = string
    identity_id          = string
    boot_diagnostics_uri = string
  })
  default = {
    resource_group_name  = null
    location             = null
    tags                 = {}
    vm_size              = null
    storage_account_type = null
    admin_username       = null
    admin_ssh_public_key = null
    additional_ssh_keys  = null
    subnet_id            = null
    identity_id          = null
    boot_diagnostics_uri = null
  }
}



variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Azure tags object."
  type        = map
  default     = {}
}

variable "subnet_id" {
  description = "Resource ID for the subnet to attach the NIC to."
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "Virtual machine SKU name."
  type        = string
  default     = ""
}

variable "storage_account_type" {
  description = "Either Standard_LRS (default), StandardSSD_LRS or Premium_LRS."
  type        = string
  default     = ""
}

variable "key_vault_id" {
  description = "Resource ID for key_vault_id containing public SSH keys."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "Admin username. Requires matching secret in keyvault with the public key."
  type        = string
  default     = ""
}

variable "admin_ssh_public_key" {
  description = "SSH public key string for admin_username. E.g. file(~/.ssh/id_rsa.pub)."
  type        = string
  default     = ""
}

variable "additional_ssh_keys" {
  description = "List of additional admin users and their SSH public keys"
  type = list(object({
    username   = string
    public_key = string
  }))
  default = []
}

variable "identity_id" {
  description = "Resource ID for a user assigned managed identity."
  type        = string
  default     = null
}

variable "boot_diagnostics_uri" {
  description = "Blob URI for the boot diagnostics storage account."
  type        = string
  default     = ""
}

// ==============================================================================

variable "application_security_group_ids" {
  description = "List of application security group resource IDs."
  type        = list(string)
  default     = null
}

variable "availability_set_ids" {
  description = "List of availability set resource IDs."
  type        = list(string)
  default     = null
}

variable "load_balancer_backend_address_pool_ids" {
  description = "List of load balancer's backend pool resource IDs."
  type        = list(string)
  default     = null
}

variable "application_gateway_backend_address_pool_ids" {
  description = "List of application gateway's backend pool resource IDs."
  type        = list(string)
  default     = null
}

// ==============================================================================

variable "module_depends_on" {
  type    = list(any)
  default = []
}
