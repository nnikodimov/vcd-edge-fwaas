# Terrafrom Initialization
terraform {
  required_version = ">= 0.13"
  required_providers {
    vcd = {
      source = "vmware/vcd"
      version = "3.12.0"
    }
  }
}

# Connect VMware vCloud Director Provider

provider "vcd" {
  user = var.vcd_user
  password = var.vcd_pass
  org = "System"
  url = var.vcd_url
  max_retry_timeout = var.vcd_max_retry_timeout
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
}
