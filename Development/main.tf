terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  
}

module "templates" {
  source = "./templates"
}

# provider "vault" {

# }

# provider "vault" {
#     VAULT_ADDR = "https://vault-cluster-public-vault-491ec396.2442a5d1.z1.hashicorp.cloud:8200/"
#     VAULT_TOKEN = "hvs.CAESILW7vekJEfqZBzLNku-y2NEQO4Rtkki3t1yj1At2OM5MGigKImh2cy5oSTRlT2J6WVY3VDA5VWRRalFwcHB6M0guN0JiekkQ1sYE"
# }

