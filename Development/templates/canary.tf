# resource "aws_synthetics_canary" "some2" {
#   name                 = "canary2"
#   artifact_s3_location = "s3://dev198448550418canaryscript/"
#   execution_role_arn   = aws_iam_role.test.arn
#   handler              = "pageLoadBlueprint.handler"
#   zip_file             = "index.zip"
#   runtime_version      = "syn-nodejs-puppeteer-3.7"

#   schedule {
#     expression = "rate(1 hour)"
#   }
# }

# resource "aws_synthetics_canary" "some3" {
#   name                 = "canary3"
#   artifact_s3_location = "s3://dev198448550418canaryscript/"
#   execution_role_arn   = aws_iam_role.test.arn
#   handler              = "exports.handler"
#   zip_file             = "index.zip"
#   runtime_version      = "syn-nodejs-puppeteer-3.7"

#   schedule {
#     expression = "rate(1 hour)"
#   }
# }


resource "aws_synthetics_canary" "sswebsite2" {
  name                 = "sswebsite2"
  artifact_s3_location = "s3://dev198448550418canaryscript/"
  execution_role_arn   = aws_iam_role.test.arn
  handler              = "sswebsite2.handler"
  zip_file             = "Development/templates/sswebsite2/sswebsite2v1.zip"
  runtime_version      = "syn-nodejs-puppeteer-3.5"
  start_canary = true

  run_config {
    active_tracing = true
    memory_in_mb = 960
    timeout_in_seconds = 60
  }
  schedule {
    expression = "rate(1 minute)"
  }
}



locals {
  cw_syn_target = {
    "target_name" = "pageLoadBuilderBlueprint.js"
  }
}

data "archive_file" "cw_syn_function" {
  for_each = local.cw_syn_target

  type        = "zip"
  source_dir  = "Development/canary/"
  output_path = "Development/canary/index.zip"
}

resource "aws_synthetics_canary" "cw_syn_canary" {
  #for_each = local.cw_syn_target

  artifact_s3_location     = "s3://dev198448550418canaryscript/canary/"
  execution_role_arn       = aws_iam_role.test.arn
  #failure_retention_period = 31
  handler                  = "pageLoadBuilderBlueprint.handler"
  #zip_file                 = "data.archive_file.cw_syn_function.output_path"
  zip_file                 = "Development/canary/index.zip"
  name                     = "yura"
  runtime_version          = "syn-nodejs-puppeteer-3.6"
  #success_retention_period = 31
  tags = {
    "blueprint" = "pageload"
  }
  tags_all = {
    "blueprint" = "pageload"
  }

  run_config {
    active_tracing = false
    environment_variables = {
      URL = "https://google.com/"
    }
    #memory_in_mb      = 1000
    timeout_in_seconds = 60
  }

  schedule {
    duration_in_seconds = 0
    expression          = "rate(1 minute)"
  }
}




# resource "aws_synthetics_canary" "some_canary_test" {
#   name                 = "some_canary_test"
#   artifact_s3_location = "s3://dev198448550418canaryscript/"
#   execution_role_arn   = aws_iam_role.test.arn
#   handler              = "pageLoadBlueprint.handler"

#   zip_file             = "index.zip"

#   runtime_version      = "syn-nodejs-puppeteer-3.5"

#   schedule {
#     expression = "rate(1 hour)"
#   }
# }


resource "aws_iam_role" "test" {
  name = "test1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test" {
  name = "test"
  role = aws_iam_role.test.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "canary_script" {
    bucket                    = "${var.environment}${local.account_id}canaryscript"
    #force_destroy            = false
    force_destroy             = true
}

# resource "aws_s3_bucket_object" "canary_script" {
#   key        = "canaryscript"
#   bucket     = aws_s3_bucket.canary_script.id
#   #source     = "index.js"
# }


# resource "aws_synthetics_canary" "saints-xctf-up" {
#   name = "sxctf-up-dev"
#   artifact_s3_location = "s3://dev198448550418canaryscript/"
#   execution_role_arn = aws_iam_role.test.arn
#   runtime_version = "syn-nodejs-puppeteer-3.5"
#   handler = "up.handler"
#   zip_file = "${path.module}/SaintsXCTFUp.zip"
#   start_canary = false

#   success_retention_period = 2
#   failure_retention_period = 14

#   schedule {
#     expression = "rate(1 hour)"
#     duration_in_seconds = 300
#   }

#   run_config {
#     timeout_in_seconds = 300
#     memory_in_mb = 960
#     active_tracing = false
#   }

#   tags = {
#     Name = "sxctf-up-ded"
#     Environment = "dev"
#     Application = "saints-xctf"
#   }
# }