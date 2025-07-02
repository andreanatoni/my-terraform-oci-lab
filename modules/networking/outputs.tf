output "lab_vcn" {
  description = "OCID of the lab_vcn"
  value       = oci_core_vcn.lab_vcn.id
}

output "lab_subnet_public_1" {
  description = "OCID of the public_1 subnet"
  value       = oci_core_subnet.lab_subnet_public_1.id
}

output "lab_subnet_private_1" {
  description = "OCID of the private_1 subnet"
  value       = oci_core_subnet.lab_subnet_private_1.id
}

output "lab_subnet_private_2" {
  description = "OCID of the private_2 subnet"
  value       = oci_core_subnet.lab_subnet_private_2.id
}



