resource "oci_core_instance_configuration" "app_config" {
  compartment_id = var.compartment_id
  display_name = var.config_name

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.compartment_id
      shape = var.shape

      shape_config {
        ocpus = var.ocpus
        memory_in_gbs = var.memory_in_gbs
      }

      source_details {
        source_type = "image"
        image_id = var.image_id
      }

      create_vnic_details {
        assign_public_ip = false
        subnet_id = var.subnet_id_private
      }

      metadata = {
        ssh_authorized_keys = file(var.ssh_public_key_path)
        user_data = base64encode(file(var.cloud_init_path))
      }
    }
  }
}
