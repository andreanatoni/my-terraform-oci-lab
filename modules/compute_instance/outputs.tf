output "vm_name" {
  value = oci_core_instance.vm.display_name
}

output "vm_public_ip" {
  value = oci_core_instance.vm.public_ip
}

output "instance_ip_address" {
  value = oci_core_instance.your_instance_name.private_ip
}