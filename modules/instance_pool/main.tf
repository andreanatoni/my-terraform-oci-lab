resource "oci_core_instance_pool" "lab_instance_pool" {
  
  compartment_id = var.compartment_id
  display_name = var.instance_pool_name
  size = var.instance_pool_size

  instance_configuration_id = var.instance_configuration_id

  instance_display_name_formatter = "web-server-instance-$${launchCount}"
  instance_hostname_formatter     = "websvr-$${launchCount}"

  # Genera un blocco placement_configurations per ogni AD nella lista
dynamic "placement_configurations" {
  for_each = var.ad_list
  content {
    availability_domain = placement_configurations.value
    primary_subnet_id   = var.subnet_id_private
  }
}

}

data "oci_core_instance_pool_instances" "lab_instance_pool" {
  compartment_id        = var.compartment_id
  instance_pool_id      = oci_core_instance_pool.lab_instance_pool.id
}