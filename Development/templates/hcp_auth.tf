###   AWS auth method enabling ####
resource "vault_auth_backend" "aws" {
  type                        = "aws"
}

###   AWS iam user creds add to AWS auth method  ####
resource "vault_aws_auth_backend_client" "aws_iam_user" {
  backend                     = vault_auth_backend.aws.path
  access_key                  = aws_iam_access_key.hcp_auth_key.id
  secret_key                  = aws_iam_access_key.hcp_auth_key.secret
}
### AWS auth method role setup  ####
resource "vault_aws_auth_backend_role" "hcp_aws_access_role" {
  role                       = "hcp_aws_auth_role"
  backend                    = vault_auth_backend.aws.path
  auth_type                  = "iam"
  bound_iam_principal_arns   = [aws_iam_role.codebuild_role.arn] #Allows authorization for resources with such role attached
  token_policies             = ["admins"] #Defines policy for temp token.(find in )
}


#Creates token for Terraform Cloud auth
resource "vault_terraform_cloud_secret_backend" "terraform" {
  backend     = "terraform"
  description = "Manages the Terraform Cloud backend"
  token       = var.TF_TOKEN
}

resource "vault_terraform_cloud_secret_role" "terraform_role" {
  backend      = vault_terraform_cloud_secret_backend.terraform.backend
  name         = "terraform-role"
  organization = "TerraCloudZoom"
}

resource "vault_terraform_cloud_secret_creds" "token" {
  backend = vault_terraform_cloud_secret_backend.terraform.backend
  role    = vault_terraform_cloud_secret_role.terraform_role.name
}