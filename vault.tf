provider "vault" {
  address = "http://10.42.42.6:8200"
  skip_tls_verify = true
}

# Proxmox authentication for terraform
data "vault_generic_secret" "proxmox_auth" {
    path = "secrets/proxmox/terraform_auth"
}
