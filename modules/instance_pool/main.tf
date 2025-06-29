resource "oci_core_instance_pool" "lab_instance_pool" {
  compartment_id = var.compartment_id
  display_name = "lab-instance-pool"
  size = var.instance_pool_size

  instance_configuration_id = oci_core_instance_configuration.lab_instance_configuration.id

  # Optional: Define the placement configuration if needed
  placement_configurations {
    availability_domain = var.availability_domain
  }
  
}