variable "compartment_id" {
  type = string
  default = "ocid1.tenancy.oc1..aaaaaaaawxav5xaxqcjz2xeqwbrjc6nlkdmzuxt6gs2j434skcomz7jzgjaa"
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

variable "region_id" {
  description = "OCI region"
  type        = string
  default     = "uk-london-1"
}
