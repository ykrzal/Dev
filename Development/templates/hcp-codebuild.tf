resource "aws_codebuild_project" "hcp-codebuild" {
  name          = "test-hcp-kv-project"
  description   = "test_codebuild_project"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }



  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name                      = "VAULT_ADDR"
      value                     = hcp_vault_cluster.hcp_tf_vault.vault_private_endpoint_url
    }

    environment_variable {
      name                      = "VAULT_NAMESPACE"
      value                     = "admin"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name                = "log-group-hcp-build"
      stream_name               = "log-stream-hcp-build"
    }


  source {
    type                        = "NO_SOURCE"
    buildspec                   = "Development/templates/buildspec/buildspec_test_hcp_kv.yml"
  }

  vpc_config {
    vpc_id                      = aws_vpc.main_vpc.id

    subnets                     = ["${aws_subnet.private_codebuild.*.id[0]}", "${aws_subnet.private_codebuild.*.id[1]}"]

    security_group_ids          = [aws_security_group.codebuild.id]
    }

  }
}
