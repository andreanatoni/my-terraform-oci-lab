output "vm_name" {
  value = oci_core_instance.vm.display_name
}

output "instance_ip_address" {
  value = oci_core_instance.vm.private_ip
}

data "oci_core_vnic_attachments" "vm_vnic" {
  instance_id = oci_core_instance.vm.id
  compartment_id = var.compartment_id
}

data "oci_core_vnic" "vm_vnic" {
  vnic_id = data.oci_core_vnic_attachments.vm_vnic.vnic_attachments[0].vnic_id
}

output "vm_public_ip" {
  value = data.oci_core_vnic.vm_vnic.public_ip_address
}