output "instance_pool_id" {
  description = "The OCID of the created instance pool"
  value       = oci_core_instance_pool.lab_instance_pool.id
}

output "pool_instances" {
  value = data.oci_core_instance_pool_instances.lab_instance_pool.instances
}

output "instance_pool_size" {
  value = oci_core_instance_pool.lab_instance_pool.size

}