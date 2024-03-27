data "vcd_org" "org1" {
  name = var.vcd_org
}

data "vcd_org_vdc" "vdc1" {
  org  = var.vcd_org
  name = var.vcd_org_vdc1
}

data "vcd_org_user" "org_user1" {
  org  = var.vcd_org
  name = var.vcd_org_admin
}

data "vcd_org_user" "org_user2" {
  org  = var.vcd_org
  name = var.vcd_org_security_admin
}

data "vcd_nsxt_edgegateway" "edge1" {
  org = data.vcd_org.org1.name
  owner_id = data.vcd_org_vdc.vdc1.id
  name = var.vcd_org_vdc1_edge1
}

data "vcd_nsxt_app_port_profile" "app_port1" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "DNS-UDP"
}

data "vcd_nsxt_app_port_profile" "app_port2" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "DNS-TCP"
}

data "vcd_nsxt_app_port_profile" "app_port3" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "MS_RPC_UDP"
}

data "vcd_nsxt_app_port_profile" "app_port4" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "MS_RPC_TCP"
}

data "vcd_nsxt_app_port_profile" "app_port5" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "LDAP"
}

data "vcd_nsxt_app_port_profile" "app_port6" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "Microsoft Active Directory V1"
}

data "vcd_nsxt_app_port_profile" "app_port7" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "HTTP"
}

data "vcd_nsxt_app_port_profile" "app_port8" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "HTTPS"
}

data "vcd_network_routed_v2" "net1" {
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge1.id
  name            = "vdi-network"
}

resource "vcd_nsxt_ip_set" "ipset1" {
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge1.id
  name        = "SHARED-SERVICES"
  description = "IP Set containing AD, DNS and DHCP"
  ip_addresses = [
    "192.168.110.10"
  ]
}

resource "vcd_nsxt_security_group" "vdi" {
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge1.id
  name        = "VDI"
  description = "Security Group for VDI environment"
  member_org_network_ids = [data.vcd_network_routed_v2.net1.id]
}

resource "vcd_nsxt_firewall" "VDI-Policy" {
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge1.id
  rule {
    action               = "ALLOW"
    name                 = "Allow DNS"
    direction            = "IN_OUT"
    ip_protocol          = "IPV4_IPV6"
    source_ids           = [vcd_nsxt_security_group.vdi.id]
    destination_ids      = [vcd_nsxt_ip_set.ipset1.id]
    app_port_profile_ids = [data.vcd_nsxt_app_port_profile.app_port1.id,data.vcd_nsxt_app_port_profile.app_port2.id]
  }
  
  rule {
    action               = "ALLOW"
    name                 = "Allow MS_RPC"
    direction            = "IN_OUT"
    ip_protocol          = "IPV4_IPV6"
    source_ids           = [vcd_nsxt_security_group.vdi.id,vcd_nsxt_ip_set.ipset1.id]
    destination_ids      = [vcd_nsxt_ip_set.ipset1.id,vcd_nsxt_security_group.vdi.id]
    app_port_profile_ids = [data.vcd_nsxt_app_port_profile.app_port3.id,data.vcd_nsxt_app_port_profile.app_port4.id]
  }
 
  rule {
    action               = "ALLOW"
    name                 = "Allow LDAP"
    direction            = "IN_OUT"
    ip_protocol          = "IPV4_IPV6"
    source_ids           = [vcd_nsxt_security_group.vdi.id,vcd_nsxt_ip_set.ipset1.id]
    destination_ids      = [vcd_nsxt_ip_set.ipset1.id,vcd_nsxt_security_group.vdi.id]
    app_port_profile_ids = [data.vcd_nsxt_app_port_profile.app_port5.id]
  }
  
  rule {
    action               = "ALLOW"
    name                 = "Allow Active Directory"
    direction            = "IN_OUT"
    ip_protocol          = "IPV4_IPV6"
    source_ids           = [vcd_nsxt_security_group.vdi.id,vcd_nsxt_ip_set.ipset1.id]
    destination_ids      = [vcd_nsxt_ip_set.ipset1.id,vcd_nsxt_security_group.vdi.id]
    app_port_profile_ids = [data.vcd_nsxt_app_port_profile.app_port6.id]
  }
  
  rule {
    action               = "ALLOW"
    name                 = "Allow HTTP/S Outbound"
    direction            = "IN_OUT"
    ip_protocol          = "IPV4_IPV6"
    source_ids           = [vcd_nsxt_security_group.vdi.id]
    app_port_profile_ids = [data.vcd_nsxt_app_port_profile.app_port7.id,data.vcd_nsxt_app_port_profile.app_port8.id]
  }
}
