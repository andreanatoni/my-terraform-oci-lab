variable "tenancy_id" {
  type = string
}

variable "compartment_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "image_id" {
  description = "OCID of the image to use for the compute instance"
  type        = string
}

variable "shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "instance_name" {
  type    = string
  default = "my-vm"
}

variable "hostname_label" {
  type    = string
  default = "myvm"
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ocpus" {
  description = "Number of OCPUs for the instance"
  type        = number
  default     = 1
}

variable "memory_in_gbs" {
  description = "Amount of memory (in GBs) for the instance"
  type        = number
  default     = 8
}

variable "instance_ip_address" {
  description = "IP address for the instance"
  type        = string
  default     = null
}