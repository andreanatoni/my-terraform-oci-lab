terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=4.67.3"
    }
  }
  required_version = ">= 1.0.0"
}

module "networking" {
  source         = "./modules/networking"
  compartment_id = var.compartment_id
}