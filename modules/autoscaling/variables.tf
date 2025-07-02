variable "compartment_id" {
  description = "OCID of the compartment where the autoscaling configuration will be created"
  type        = string
}

variable "lab_instance_pool_id" {
  description = "OCID of the instance pool to be used for autoscaling"
  type        = string
}