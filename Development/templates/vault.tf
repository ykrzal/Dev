resource "hcp_hvn" "hcp_tf_hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = var.cloud_provider
  region         = var.region
}

resource "hcp_vault_cluster" "hcp_tf_vault" {
  hvn_id     = hcp_hvn.hcp_tf_hvn.hvn_id
  cluster_id = var.cluster_id
  tier       = var.tier
  #public_endpoint = true
}