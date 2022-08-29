resource "aws_iam_user" "hcp_auth" {
  name = "hcp_auth_user"
  path = "/"
}

resource "aws_iam_access_key" "hcp_auth_key" {
  user = aws_iam_user.hcp_auth.name
}

resource "aws_iam_user_policy" "hcp_up" {
  name = "aws-policy-for-hcp-vault-authmethod"
  user = aws_iam_user.hcp_auth.name

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
 {
   "Effect": "Allow",
   "Action": [
     "iam:GetInstanceProfile",
     "iam:GetUser",
     "iam:ListRoles",
     "iam:GetRole"
   ],
   "Resource": "*"
 }
 ]
}
EOF
}