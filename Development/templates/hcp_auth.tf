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


#Creates token for service auth
resource "vault_token" "hcp_vault_token" {
  # role_name                  = "hcp_vault_auth_role"
  policies                   = ["admins"]
  no_parent                  = true
  renewable                  = false

  metadata = {
    "purpose"                = "service-account"
  }
}