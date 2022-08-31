terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.23.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.41.0"
     }
  }
}

provider "aws" {
  region = "us-east-2"
  
}

module "templates" {
  source = "./templates"
}

provider "vault" {
  # address =  module.templates.hcp_vault_cluster.hcp_tf_vault.vault_public_endpoint_url
  # token   =  module.templates.vault_token.hcp_vault_token.client_token
}

provider "hcp" {}


