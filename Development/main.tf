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

provider "vault" {}

provider "hcp" {}


