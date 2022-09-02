locals {
  canary_name                   = "test"
  canary_timeout_in_seconds     = 30
  canary_memory_limit_in_mb     = 960
  canary_active_tracing_enabled = false
  canary_environment_variables  = { ENV: "DEV" }
  set_canary_run_config_command = "aws synthetics update-canary --name ${local.canary_name} --run-config '${jsonencode({TimeoutInSeconds: local.canary_timeout_in_seconds, MemoryInMB: local.canary_memory_limit_in_mb, ActiveTracing: local.canary_active_tracing_enabled, EnvironmentVariables: local.canary_environment_variables })}'"
}

resource "aws_synthetics_canary" "healthchecks" {
  name                      = local.canary_name
  start_canary              = true
  s3_bucket                 = aws_s3_bucket_object.canary_script.bucket
  s3_key                    = aws_s3_bucket_object.canary_script.key
  artifact_s3_location      = "s3://${aws_s3_bucket.canary_script.id}/"
  execution_role_arn        = aws_iam_role.test.arn
  handler                   = "apiCanaryBlueprint.handler"
  runtime_version           = "syn-nodejs-puppeteer-3.3"

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    active_tracing      = local.canary_active_tracing_enabled
    memory_in_mb        = local.canary_memory_limit_in_mb
    timeout_in_seconds  = local.canary_timeout_in_seconds
  }
}

# resource "null_resource" "add_environment_variables_to_canary" {
#   # Run this command again whenever any of the run-config parameters change
#   triggers = {
#     canary_active_tracing_enabled = local.canary_active_tracing_enabled
#     canary_memory_limit_in_mb     = local.canary_memory_limit_in_mb
#     canary_timeout_in_seconds     = local.canary_timeout_in_seconds
#     # Trigger values must be strings (or implicitly coerced into strings, like bools), so turn env vars into a string like FOO=bar,FIZZ=buzz
#     canary_environment_variables  = join(",", [ for key, value in local.canary_environment_variables: "${key}=${value}" ])
#   }
#   provisioner "local-exec" {
#     command = local.set_canary_run_config_command
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

resource "aws_s3_bucket_object" "canary_script" {
  key        = "canaryscript"
  bucket     = aws_s3_bucket.canary_script.id
  #source     = "index.js"
}