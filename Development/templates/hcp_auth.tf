# resource "vault_auth_backend" "userpass" {
#   type = "userpass"
# }

# # Create a user, 'student'
# resource "vault_generic_endpoint" "student" {
#   depends_on           = [vault_auth_backend.userpass]
#   path                 = "auth/userpass/users/student"
#   ignore_absent_fields = true

#   data_json = <<EOT
# {
#   "policies": ["admins", "eaas-client"],
#   "password": "test"
# }
# EOT
# }

resource "vault_auth_backend" "aws" {
  type = "aws"
  path = "aws"
}

resource "vault_aws_auth_backend_client" "aws_iam_user" {
  backend    = vault_auth_backend.aws.path
  access_key = aws_iam_access_key.hcp_auth_key.id
  secret_key = aws_iam_access_key.hcp_auth_key.secret
}

resource "vault_aws_auth_backend_role" "hcp_aws_access_role" {
  backend                         = vault_auth_backend.aws.path
  auth_type                       = "iam"
  bound_iam_principal_arn         = aws_iam_role.ecs_tasks_execution_role.arn
  token_policies                  = ["admin"]
}