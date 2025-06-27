resource oci_load_balancer_load_balancer lab_public_load_balancer {
  compartment_id = var.compartment_id
  display_name = "lab-public-load-balancer"

  ip_mode    = "IPV4"
  is_private = "false"
  shape = "100Mbps"
  subnet_ids = [
    oci_core_subnet.lab_subnet_public_1.id
  ]
}

resource oci_load_balancer_backend_set lab_backend_set {
  load_balancer_id = oci_load_balancer_load_balancer.lab_public_load_balancer.id
  name              = "lab-backend-set"
  policy            = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    url_path = "/"
    port    = 80
    return_code = "200"
    interval_in_millis = 10000
    timeout_in_millis = 2000
    retries = 3
  }
}

# Recupera le istanze del pool

data "oci_core_instance_pool_instances" "pool_instances" {
  compartment_id   = var.compartment_id
  instance_pool_id = oci_core_instance_pool.your_instance_pool.id
}

# Recupera gli attachment delle VNIC per le istanze del pool

data "oci_core_vnic_attachments" "vnic_attachments" {
  for_each       = toset(data.oci_core_instance_pool_instances.pool_instances.instances[*].id)
  compartment_id = var.compartment_id
  instance_id    = each.value
}

# Recupera le VNIC associate agli attachment (da cui ricavi l'IP)

data "oci_core_vnic" "vnics" {
  for_each = data.oci_core_vnic_attachments.vnic_attachments
  vnic_id  = each.value.vnic_attachments[0].vnic_id
}

# Aggiungi i backend al backend set del load balancer

resource "oci_load_balancer_backend" "lab_backends" {
  for_each = data.oci_core_vnic.vnics

  load_balancer_id = oci_load_balancer_load_balancer.lab_public_load_balancer.id
  backend_set_name = oci_load_balancer_backend_set.lab_backend_set.name
  ip_address       = each.value.private_ip
  port             = 80
  weight           = 1
}

# Listener per il Load Balancer

resource oci_load_balancer_listener lab_listener {
  load_balancer_id = oci_load_balancer_load_balancer.lab_public_load_balancer.id
  name              = "lab-listener"
  port              = 80
  protocol          = "HTTP"

  default_backend_set_name = oci_load_balancer_backend_set.lab_backend_set.name
}

