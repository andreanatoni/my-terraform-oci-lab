# Creo la VCN e i relativi componenti
resource "oci_core_vcn" "lab_vcn" {
  compartment_id = var.compartment_id
  display_name   = "LAB-VCN-01"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "labvcn"
}

# Internet Gateway
resource "oci_core_internet_gateway" "lab_igw" {
  compartment_id = var.compartment_id
  display_name   = "LAB-IGW"
  vcn_id         = oci_core_vcn.lab_vcn.id
}

# NAT Gateway
resource "oci_core_nat_gateway" "lab_nat_gw" {
  compartment_id = var.compartment_id
  display_name   = "LAB-NAT-GW"
  vcn_id         = oci_core_vcn.lab_vcn.id
}

# Service Gateway
resource "oci_core_service_gateway" "lab_sgw" {
  compartment_id = var.compartment_id
  display_name   = "LAB-SGW"
  vcn_id         = oci_core_vcn.lab_vcn.id

  services {
    service_id = data.oci_core_services.oci_services.services[0].id
  }
}

# Ottiengo la lista dei servizi disponibili per la Service Gateway
data "oci_core_services" "oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Route Tables

# Route Table - Public

resource "oci_core_route_table" "lab_public_rt" {
  compartment_id = var.compartment_id
  display_name   = "LAB-RT-PUBLIC"
  vcn_id         = oci_core_vcn.lab_vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.lab_igw.id
  }
}

# Route Table - Private

resource "oci_core_route_table" "lab_private_rt" {
  compartment_id = var.compartment_id
  display_name   = "LAB-RT-PRIVATE"
  vcn_id         = oci_core_vcn.lab_vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.lab_nat_gw.id
  }

  route_rules {
    destination       = data.oci_core_services.oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.lab_sgw.id
  }
}

# Security Lists

resource "oci_core_security_list" "lab_sl_private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "LAB-SECLIST-PRIVATE"
  
  # ===== INGRESS RULES =====
  
  # ICMP (ping) dalla subnet pubblica
  ingress_security_rules {
    protocol    = "1"  # ICMP
    source      = "10.0.0.0/24"  # Subnet pubblica
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
  
  # ICMP (ping) interna alla VCN
  ingress_security_rules {
    protocol    = "1"  # ICMP
    source      = "10.0.0.0/16"  # Tutta la VCN
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
  
  # SSH dalla subnet pubblica
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "10.0.0.0/24"  # Subnet pubblica
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
    stateless = false
  }
  
  # HTTP dalla subnet pubblica (per load balancer)
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "10.0.0.0/24"  # Subnet pubblica
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 80
      max = 80
    }
    stateless = false
  }
  
  # HTTPS dalla subnet pubblica
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "10.0.0.0/24"  # Subnet pubblica
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
    stateless = false
  }
  
  # Comunicazione interna tra istanze private
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = "10.0.1.0/24"  # Subnet privata
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
  
  # ===== EGRESS RULES =====
  
  # Tutto il traffico uscente
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
  }
}

# Aggiorna anche la security list pubblica per completezza:

resource "oci_core_security_list" "lab_sl_public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "LAB-SECLIST-PUBLIC"
  
  # ===== INGRESS RULES =====
  
  # HTTP da Internet
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 80
      max = 80
    }
    stateless = false
  }
  
  # HTTPS da Internet
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
    stateless = false
  }
  
  # SSH da Internet
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
    stateless = false
  }
  
  # ICMP da Internet (per ping)
  ingress_security_rules {
    protocol    = "1"  # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
  
  # ===== EGRESS RULES =====
  
  # Tutto il traffico uscente
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
  }
}

# Ottengo la security list di default

resource "oci_core_default_security_list" "default_sl" {
  compartment_id             = var.compartment_id
  manage_default_resource_id = oci_core_vcn.lab_vcn.default_security_list_id
  display_name               = "Defaul Security List"
}

# Subnets

# Public 1
resource "oci_core_subnet" "lab_subnet_public_1" {
  compartment_id             = var.compartment_id
  display_name               = "LAB-SNT-PUBLIC-1"
  vcn_id                     = oci_core_vcn.lab_vcn.id
  cidr_block                 = "10.0.0.0/24"
  route_table_id             = oci_core_route_table.lab_public_rt.id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "labsntpublic1"
  security_list_ids = [
    oci_core_security_list.lab_sl_public.id,
    oci_core_default_security_list.default_sl.id
  ]
}

# Private 1
resource "oci_core_subnet" "lab_subnet_private_1" {
  compartment_id             = var.compartment_id
  display_name               = "LAB-SNT-PRIVATE-1"
  vcn_id                     = oci_core_vcn.lab_vcn.id
  cidr_block                 = "10.0.1.0/24"
  route_table_id             = oci_core_route_table.lab_private_rt.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "labsntprivate1"
  security_list_ids = [
    oci_core_security_list.lab_sl_private.id,
    oci_core_default_security_list.default_sl.id
  ]
}

# Private 2
resource "oci_core_subnet" "lab_subnet_private_2" {
  compartment_id             = var.compartment_id
  display_name               = "LAB-SNT-PRIVATE-2"
  vcn_id                     = oci_core_vcn.lab_vcn.id
  cidr_block                 = "10.0.2.0/24"
  route_table_id             = oci_core_route_table.lab_private_rt.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "labsntprivate2"
  security_list_ids = [
    oci_core_security_list.lab_sl_private.id,
    oci_core_default_security_list.default_sl.id
  ]
}