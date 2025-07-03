variable "instance_pool_name" {
  description = "The name of the instance pool."
  type        = string
  default = "lab_intance_pool"
}

variable "compartment_id" {
  description = "The OCID of the compartment in which to create the instance pool"
  type        = string
}

variable "instance_pool_size" {
  description = "The size of the instance pool."
  type        = number
  default     = 1
}

variable "ad_list" {
  description = "Lista di availability domain names da usare nel pool"
  type        = list(string)
}

variable "instance_configuration_id" {
  description = "OCID of the instance configuration to use"
  type        = string
}

variable "subnet_id_private" {
  description = "The OCID of the private subnet for the instance pool"
  type        = string
}
