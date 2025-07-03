variable "compartment_id" {
  type = string
}

variable "lab_instance_config_name" {
  type    = string
  default = "app-instance-config"
}

variable "shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  type    = number
  default = 1
}

variable "memory_in_gbs" {
  type    = number
  default = 8
}

variable "subnet_id_private" {
  type = string
}

variable "ssh_public_key" {
  description = "Contenuto della chiave pubblica SSH"
  type        = string
}

variable "cloud_init_path" {
  description = "Path to the cloud-init script to execute at first boot"
  type        = string
  default     = "./scripts/cloud-init.sh"
}