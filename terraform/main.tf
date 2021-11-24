terraform {
  backend "s3" {
    bucket = "terraform"
    key = "terraform.tfstate"
    region = "us-east-1"
    endpoint = "http://minio:9000"
    force_path_style = true
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_get_ec2_platforms = true
    skip_metadata_api_check = true
    skip_region_validation = true
  }
}

provider "proxmox" {
  pm_api_url      = "https://10.42.42.42:8006/api2/json"
  pm_user         = data.vault_generic_secret.proxmox_auth.data["user"]
  pm_password     = data.vault_generic_secret.proxmox_auth.data["pass"]
  pm_tls_insecure = true
}

provider "vault" {
  address = "http://vault:8200"
  skip_tls_verify = true
}

# Proxmox authentication for terraform
data "vault_generic_secret" "proxmox_auth" {
    path = "secrets/terraform/proxmox_credentials"
}

# Imported from hosts.auto.tfvars.json
variable "hosts" { }
