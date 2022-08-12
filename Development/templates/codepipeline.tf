resource "aws_s3_bucket" "s3_logging_bucket" {
    bucket          = "${var.environment}-${local.account_id}-codebuild-logs"
    #force_destroy   = false
    force_destroy   = true
}

resource "aws_s3_bucket" "codepipeline_artifact_bucket" {
    bucket          = "${var.environment}-${local.account_id}-codepipeline-artifact-bucket"
    #force_destroy   = false
    force_destroy   = true
}

#################################################################
############# Build/Deploy Admin static site ####################
#################################################################

resource "aws_codebuild_project" "codebuild_project_admin_site" {
  name          = "${var.environment}-build-admin-site"
  description   = "Build codebuild project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "aws_s3_bucket.s3_logging_bucket"
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
      location = "aws_s3_bucket.s3_logging_bucket"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/buildspec_staticsite.yml"
  }
}

################## Deploy New Version ###########################
resource "aws_codebuild_project" "codebuild_deploy_admin_site" {
  name          = "${var.environment}-deploy-admin-site"
  description   = "Deploy codebuild project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "aws_s3_bucket.s3_logging_bucket"
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
      location = "aws_s3_bucket.s3_logging_bucket"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/buildspec_staticsite.yml"
  }
}

##################### Pipeline for Admin Site ###########################
resource "aws_codepipeline" "codepipeline_admin_site" {
  name     = "${var.environment}-admin-site"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "aws_s3_bucket.codepipeline_artifact_bucket"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName = var.admin_repository_name
        BranchName     = var.admin_repository_branch
      }
    }
  }

  stage {
    name = "Build Admin API"

    action {
      name             = "build-admin-api"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project_admin_site
      }
    }
  }

stage {
  name = "Apporve-Swap"

  action {
    name     = "Apporve-Swap"
    category = "Approval"
    owner    = "AWS"
    provider = "Manual"
    version  = "1"
  }
}

  stage {
    name = "Terraform_Apply"

    action {
      name            = "Terraform-Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_deploy_admin_site
      }
    }
  }
}
