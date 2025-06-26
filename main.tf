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