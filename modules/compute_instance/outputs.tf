output "vm_name" {
  value = oci_core_instance.vm.display_name
}

output "vm_public_ip" {
  value = oci_core_instance.vm.public_ip
}