provider "vault" {
    VAULT_ADDR    =  hcp_vault_cluster.hcp_tf_vault.vault_public_endpoint_url
    VAULT_TOKEN      =  hcp_vault_cluster_admin_token.hcp_vault_admin_token.token
}
