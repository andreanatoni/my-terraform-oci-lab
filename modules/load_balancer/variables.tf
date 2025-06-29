variable lab_subnet_public_1 {
  description = "OCID of the public subnet for the load balancer"
  type        = string
}

variable instance_ip_address {
  description = "IP address of the instance to be added to the load balancer"
  type        = string
}

variable compartment_id {
  description = "OCID of the compartment where the load balancer will be created"
  type        = string  
}

variable "instance_pool_id" {
  description = "OCID dell'instance pool da cui ricavare le istanze per i backend"
  type        = string
}

variable "load_balancer_id" {
  description = "OCID del Load Balancer da utilizzare"
  type        = string
}

variable "pool_instances" {
  description = "List of instances in the instance pool"
  type = list(object({
    id = string,
    display_name = string,
    availability_domain = string
  })) 
}
