resource "oci_load_balancer_load_balancer" "lab_public_load_balancer" {
  compartment_id = var.compartment_id
  display_name   = "lab-public-load-balancer"

  ip_mode    = "IPV4"
  is_private = "false"
  shape      = "flexible"

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 20
  }

  subnet_ids = [
    var.lab_subnet_public_1
  ]
}

resource "oci_load_balancer_backend_set" "lab_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.lab_public_load_balancer.id
  name             = "lab-backend-set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "HTTP"
    url_path          = "/"
    port              = 80
    return_code       = "200"
    interval_ms       = 10000
    timeout_in_millis = 2000
    retries           = 3
  }
}

# Recupera le istanze del pool

data "oci_core_instance_pool_instances" "lab_pool_instances" {
  compartment_id   = var.compartment_id
  instance_pool_id = var.instance_pool_id
}

locals {
  lab_instance_id_map = {
    for idx, inst in data.oci_core_instance_pool_instances.lab_pool_instances.instances :
    "instance-${idx}" => inst.id
  }
}

# Recupera gli attachment delle VNIC per le istanze del pool

data "oci_core_vnic_attachments" "vnic_attachments" {
  for_each       = local.lab_instance_id_map
  compartment_id = var.compartment_id
  instance_id    = each.value
}


# Recupera le VNIC associate agli attachment (da cui ricavi l'IP)

data "oci_core_vnic" "vnics" {
  for_each = data.oci_core_vnic_attachments.vnic_attachments
  vnic_id = try(each.value.vnic_attachments[0].vnic_id, null)
}

# Aggiungi i backend al backend set del load balancer

resource "oci_load_balancer_backend" "lab_backends" {
  for_each = {
    for k, v in data.oci_core_vnic.vnics :
    k => v if v.private_ip_address != null
  }

  load_balancer_id = oci_load_balancer_load_balancer.lab_public_load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.lab_backend_set.name
  ip_address       = each.value.private_ip_address
  port             = 80
  weight           = 1
  drain            = false
  offline          = false
}

# Listener per il Load Balancer

resource "oci_load_balancer_listener" "lab_listener" {
  default_backend_set_name = oci_load_balancer_backend_set.lab_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.lab_public_load_balancer.id
  name                     = "lab-listener"
  port                     = 80
  protocol                 = "HTTP"
}

