resource "aws_synthetics_canary" "sswebsite2" {
  name                 = "sswebsite2"
  artifact_s3_location = "s3://dev198448550418canaryscript/"
  execution_role_arn   = aws_iam_role.test.arn
  handler              = "sswebsite2.handler"
  zip_file             = "${path.module}/sswebsite2/sswebsite2v1.zip"
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



resource "aws_cloudwatch_metric_alarm" "synthetics_alarm_app1" {
  alarm_name          = "Synthetics-Alarm-App1"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"  
  treat_missing_data  = "breaching"
  dimensions = {
    CanaryName = aws_synthetics_canary.sswebsite2.id 
  }
  alarm_description = "Synthetics alarm metric: SuccessPercent  LessThanThreshold 90"
  ok_actions          = [aws_sns_topic.alerts_ci_sns_topic.arn]  
  alarm_actions     = [aws_sns_topic.alerts_ci_sns_topic.arn]
}



resource "aws_sns_topic" "alerts_ci_sns_topic" {
  name = "alerts-ci-slack-notifications"
}

# resource "aws_sns_topic_policy" "alerts_ci_sns_topic_policy" {
#   arn    = aws_sns_topic.alerts_ci_sns_topic.arn
#   policy = data.aws_iam_policy_document.alerts_ci_sns_topic_access.json
# }

# data "aws_iam_policy_document" "alerts_ci_sns_topic_access" {
#   statement {
#     actions = ["sns:Publish"]

#     principals {
#       type = "Service"
#       identifiers = [
#         "codestar-notifications.amazonaws.com"
#       ]
#     }

#     resources = [aws_sns_topic.alerts_ci_sns_topic.arn]
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