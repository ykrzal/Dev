resource "aws_codebuild_project" "hcp-codebuild" {
  name                        = "test-hcp-kv-project"
  description                 = "test"
  build_timeout               = "5"
  service_role                = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type                        = "S3"
    location                    = aws_s3_bucket.s3_logging_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    environment_variable {
      name                      = "VAULT_ADDR"
      value                     = hcp_vault_cluster.hcp_tf_vault.vault_public_endpoint_url
    }
    environment_variable {
      name                      = "VAULT_NAMESPACE"
      value                     = "admin"
    }
  }


  logs_config {
    cloudwatch_logs {
      group_name                = "log-group"
      stream_name               = "log-stream"
    }

    s3_logs {
      status                    = "ENABLED"
      location                  = "${aws_s3_bucket.s3_logging_bucket.id}/codebuild-log"
    }
  }

  source {
    type                        = "NO_SOURCE"
    buildspec = <<EOF
    version: 0.2

    phases:
      install:
        commands:
          - sudo yum install -y yum-utils
          - sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
          - sudo yum -y install vault
      build:
        commands:
          - sudo setcap -r /usr/bin/vault
          - vault login -method=aws role=hcp_aws_auth_role
          - vault kv get -mount=test1 -field=key secret
    EOF
  }

  vpc_config {
    vpc_id                    = aws_vpc.main_vpc.id
    subnets                   = ["${aws_subnet.private_codebuild.*.id[0]}", "${aws_subnet.private_codebuild.*.id[1]}"]
    security_group_ids        = [aws_security_group.codebuild.id]

}
}
