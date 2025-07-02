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
  image_id            = "ocid1.image.oc1.uk-london-1.aaaaaaaa3pzzp6xdpaijaubxeht6hfjz7ccdegksqsggrcs5jb5nzq2g6niq"
  shape               = "VM.Standard.A1.Flex"
  ssh_public_key_path = "~/.ssh/id_rsa.pub"
}

module "instance_configuration" {
  source                   = "./modules/instance_configuration"
  compartment_id           = var.compartment_id
  availability_domain      = var.availability_domain
  lab_instance_config_name = "web-server-instance-"
  image_id                 = "ocid1.image.oc1.uk-london-1.aaaaaaaa3pzzp6xdpaijaubxeht6hfjz7ccdegksqsggrcs5jb5nzq2g6niq"
  subnet_id_private        = module.networking.lab_subnet_private_1
}

module "load_balancer" {
  source              = "./modules/load_balancer"
  compartment_id      = var.compartment_id
  lab_subnet_public_1 = module.networking.lab_subnet_public_1
  instance_pool_id    = module.instance_pool.instance_pool_id
  load_balancer_id    = module.load_balancer.lab_load_balancer_id
  instance_ip_address = module.compute_instance.instance_ip_address
  pool_instances      = module.instance_pool.pool_instances
}

module "instance_pool" {
  source              = "./modules/instance_pool"
  instance_configuration_id = module.instance_configuration.lab_instance_configuration_id
  compartment_id      = var.compartment_id
  availability_domain = module.instance_configuration.availability_domain
  instance_pool_size  = var.instance_pool_size
  instance_pool_name  = var.instance_pool_name
}

module "autoscaling" {
  source               = "./modules/autoscaling"
  compartment_id       = var.compartment_id
  lab_instance_pool_id = module.instance_pool.instance_pool_id
}