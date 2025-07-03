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

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "/home/oracle/.ssh/id_rsa.pub"
}
variable "region" {
  description = "OCI region"
  type        = string
}

variable "instance_pool_size" {
  description = "The size of the instance pool."
  type        = number
  default     = 1

}

variable "instance_pool_name" {
  description = "The name of the instance pool."
  type        = string
  default     = "lab_instance_pool"

}

variable "private_key_path" {
  description = "Path to the private key for OCI authentication"
  type        = string
  default     = "~/.oci/oci_api_key.pem"
  
}