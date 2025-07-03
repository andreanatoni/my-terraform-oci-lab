locals {
  ssh_public_key = file(var.ssh_public_key_path)  # 
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

locals {
  ad_list = [
    for ad in data.oci_identity_availability_domains.ads.availability_domains :
    ad.name
  ]
}

module "networking" {
  source         = "./modules/networking"
  compartment_id = var.compartment_id
}

module "compute_instance" {
  source              = "./modules/compute_instance"
  tenancy_id          = var.tenancy_id
  compartment_id      = var.compartment_id
  subnet_id           = module.networking.lab_subnet_public_1
  instance_name       = "lab-vm-01"
  hostname_label      = "labvmb01"
  shape               = "VM.Standard.A1.Flex"
  ssh_public_key      = local.ssh_public_key
}

module "instance_configuration" {
  source                   = "./modules/instance_configuration"
  compartment_id           = var.compartment_id
  lab_instance_config_name = "web-server-instance-"
  subnet_id_private        = module.networking.lab_subnet_private_1
  ssh_public_key = local.ssh_public_key
}

module "load_balancer" {
  source              = "./modules/load_balancer"
  compartment_id      = var.compartment_id
  lab_subnet_public_1 = module.networking.lab_subnet_public_1
  instance_pool_id    = module.instance_pool.instance_pool_id
}

module "instance_pool" {
  source              = "./modules/instance_pool"
  instance_configuration_id = module.instance_configuration.lab_instance_configuration_id
  compartment_id      = var.compartment_id
  ad_list             = local.ad_list
  instance_pool_size  = var.instance_pool_size
  instance_pool_name  = var.instance_pool_name
  subnet_id_private = module.networking.lab_subnet_private_1
}

module "autoscaling" {
  source               = "./modules/autoscaling"
  compartment_id       = var.compartment_id
  lab_instance_pool_id = module.instance_pool.instance_pool_id
}