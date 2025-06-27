variable "instance_pool_name" {
  description = "The name of the instance pool."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment in which to create the instance pool"
  type        = string
}

variable "instance_pool_size" {
  description = "The size of the instance pool."
  type        = number
  default     = 2
}

variable "availability_domain" {
  description = "The availability domain to launch the instance pool in"
  type        = string
}
