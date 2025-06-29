output "instance_configuration_id" {
  value = oci_core_instance_configuration.lab_instance_configuration.id
}

output "availability_domain" {
  value = var.availability_domain
}