resource "aws_codebuild_project" "codebuild_project_admin_site" {
  name          = "${var.environment}-build-admin-site"
  description   = "Terraform codebuild project"
  build_timeout = "5"
  service_role  = var.codebuild_iam_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.s3_logging_bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "terraform"
      value = "true"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_id}/${aws_codebuild_project.codebuild_project_admin_site}/build-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/buildspec_staticsite.yml"
  }

  tags = {
    Terraform = "true"
  }
}
