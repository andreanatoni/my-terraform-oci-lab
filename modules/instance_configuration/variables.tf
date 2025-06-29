variable "compartment_id" {
  type = string
}

variable "lab_instance_config_name" {
  type = string
  default = "app-instance-config"
}

variable "shape" {
  type = string
  default = "VM.Standard.E4.Flex"
}

variable "ocpus" {
  type = number
  default = 1
}

variable "memory_in_gbs" {
  type = number
  default = 8
}

variable "image_id" {
  description = "OCID dell'immagine da usare (es. Oracle Linux)"
  type = string
}

variable "subnet_id_private" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "cloud_init_path" {
  description = "Path to the cloud-init script to execute at first boot"
  type = string
  default = "./scripts/cloud-init.sh"
}

variable "availability_domain" {
  type = string
}