terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = ">=4.67.3"
    }
  }
  required_version = ">= 1.0.0"
}

module "networking" {
  source = "./modules/networking"
  compartment_id = var.compartment_id
}

module "compute_instance" {
  source = "./modules/compute_instance"
  tenancy_id = var.tenancy_id
  compartment_id = var.compartment_id
  subnet_id = module.networking.lab_subnet_public_1
  instance_name = "web-server-01"
  hostname_label = "web01"
  image_id = "ocid1.image.oc1.uk-london-1.aaaaaaaa3pzzp6xdpaijaubxeht6hfjz7ccdegksqsggrcs5jb5nzq2g6niq"
  shape = "VM.Standard.A1.Flex"
  ssh_public_key_path = "~/.ssh/id_rsa.pub"
}

module "instance_configuration" {
  source = "./modules/instance_configuration"
  compartment_id = var.compartment_id
  subnet_id_private = module.networking.lab_subnet_private_1
  image_id = "ocid1.image.oc1.uk-london-1.aaaaaaaaxyz..."
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  cloud_init_path = "./scripts/cloud-init.sh"
}