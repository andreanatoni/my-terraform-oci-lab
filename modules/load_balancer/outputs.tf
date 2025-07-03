output "lab_load_balancer_id" {
  description = "OCID of the lab load balancer"
  value       = oci_load_balancer_load_balancer.lab_public_load_balancer.id
}

output "load_balancer_public_ip" {
  value = oci_load_balancer_load_balancer.lab_public_load_balancer.ip_address_details[0].ip_address
}