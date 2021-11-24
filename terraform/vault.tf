provider "vault" {
  address = "http://vault:8200"
  skip_tls_verify = true
}

# Proxmox authentication for terraform
data "vault_generic_secret" "proxmox_auth" {
    path = "secrets/terraform/proxmox_credentials"
}
