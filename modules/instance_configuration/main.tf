data "oci_core_images" "oracle_linux_arm" {
  compartment_id            = var.compartment_id
  operating_system          = "Oracle Linux"
  operating_system_version  = "8"
  shape                     = "VM.Standard.A1.Flex"
  sort_by                   = "TIMECREATED"
  sort_order                = "DESC"
}

resource "oci_core_instance_configuration" "lab_instance_configuration" {
  compartment_id = var.compartment_id
  display_name   = var.lab_instance_config_name

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.compartment_id
      shape          = var.shape

      shape_config {
        ocpus         = var.ocpus
        memory_in_gbs = var.memory_in_gbs
      }

      source_details {
        source_type = "image"
        image_id    = data.oci_core_images.oracle_linux_arm.images[0].id
      }

      create_vnic_details {
        assign_public_ip = false
        subnet_id        = var.subnet_id_private
      }

      metadata = {
        ssh_authorized_keys = var.ssh_public_key
        user_data = base64encode(file(var.cloud_init_path))
      }
    }
  }
}
