# Create admin policy in the root namespace
resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("Development/templates/policies/admin-policy.hcl")
}

# Create 'training' policy
resource "vault_policy" "eaas-client" {
  name   = "eaas-client"
  policy = file("Development/templates/policies/eaas-client-policy.hcl")
}