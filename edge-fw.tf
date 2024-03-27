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

data "vcd_nsxt_app_port_profile" "app-id1" {
  context_id = data.vcd_org_vdc.vdc1.id
  scope = "SYSTEM"
  name  = "DNS-UDP"
}

data "vcd_network_routed_v2" "net1" {
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge1.id
  name            = "vdi-network"
}

resource "vcd_nsxt_ip_set" "ipset1" {
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge1.id
  name        = "shared-services"
  description = "IP Set containing AD, DNS and DHCP"
  ip_addresses = [
    "192.168.110.10"
  ]
}

resource "vcd_nsxt_security_group" "vdi" {
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge1.id
  name        = "vdi"
  description = "Security Group for vdi environment"
  member_org_network_ids = [data.vcd_network_routed_v2.net1.id]
}

resource "vcd_nsxt_firewall" "l7-vdi-policy" {
#  org = data.vcd_org.id
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge1.id
  rule {
    action               = "ALLOW"
    name                 = "Allow DNS"
    direction            = "IN_OUT"
    ip_protocol          = "IPV4_IPV6"
    source_ids           = [vcd_nsxt_security_group.vdi.id]
    destination_ids      = [vcd_nsxt_ip_set.ipset1.id]
    app_port_profile_ids = [data.vcd_nsxt_app_port_profile.app-id1.id]
  }
}
