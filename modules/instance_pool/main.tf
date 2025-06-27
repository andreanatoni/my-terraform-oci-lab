resource "oci_core_instance_pool" "lab_instance_pool" {
  compartment_id = var.compartment_id
  display_name   = "lab-instance-pool"
  size           = var.instance_pool_size

  instance_configuration_id = oci_core_instance_configuration.lab_instance_configuration.id

  load_balancer {
    load_balancer_id = var.load_balancer_id
    backend_set_name = var.backend_set_name
    port = var.load_balancer_port
    vnic_selection {
      subnet_id = var.subnet_id
    }
  }

  # Optional: Define the placement configuration if needed
  placement_configurations {
    availability_domain = var.availability_domain
    fault_domain        = var.fault_domain
  }
  
}

