resource "aws_synthetics_canary" "some2" {
  name                 = "canary2"
  artifact_s3_location = "s3://dev198448550418canaryscript/"
  execution_role_arn   = aws_iam_role.test.arn
  handler              = "index.handler"
  zip_file             = "index.zip"
  runtime_version      = "syn-nodejs-puppeteer-3.7"

  schedule {
    expression = "rate(1 hour)"
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