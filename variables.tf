variable "compartment_id" {
  type = string
}

variable "tenancy_id" {
  description = "The OCID of your OCI tenancy"
  type        = string
}

variable "user_id" {
  description = "The OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "API Key fingerprint"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private API key"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
  default     = "uk-london-1"
}

variable "instance_pool_size" {
  description = "The size of the instance pool."
  type        = number
  default     = 2
  
}

variable "instance_pool_name" {
  description = "The name of the instance pool."
  type        = string
  default     = "lab_instance_pool"
  
}