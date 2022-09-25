storage_source "file" {
  path = "/var/lib/vault"
}

storage_destination "raft" {
  path = "/var/lib/vault-raft"
  node_id = "olympus-1"
}

cluster_addr = "http://vault.olympus:8201"
