#################################################################
########################## ALB ##################################
######### We will create ALB with Deletion Protection   #########
#################################################################

resource "aws_lb" "alb" {
  name               = "boopos-alb-main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all_traffic.id]
  subnets            = [aws_subnet.public.*.id[0], aws_subnet.public.*.id[1]]

  enable_deletion_protection = true

  access_logs {
    bucket            = "boopos-bucket-access-logs-${local.account_id}"
    prefix            = "bucket_access_logs"
    enabled           = true
  }

  tags = {
    Environment       = "boopos-alb-s3"
  }
}

#################################################################
######################### Data ##################################
######## Info about account ID for access from ALB to S3   ######
### Setup bucket policy to S3 and define current account ID #####
#################################################################
data "aws_elb_service_account" "main" {}

data "aws_caller_identity" "current" {}
locals {
    account_id        = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "access_from_alb" {
  statement {
    principals {
      type            = "AWS"
      identifiers     = ["${data.aws_elb_service_account.main.arn}"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.bucket_access_logs.arn,
      "${aws_s3_bucket.bucket_access_logs.arn}/*",
    ]
  }
}

#################################################################
################# S3 Bucket and policy ##########################
############ Create S3 bucket and attch bucket policy ###########
#################################################################

resource "aws_s3_bucket" "bucket_access_logs" {
    bucket          = "boopos-bucket-access-logs-${local.account_id}"
    force_destroy   = false
}

resource "aws_s3_bucket_policy" "bucket_access_logs_policy" {
  bucket            = aws_s3_bucket.bucket_access_logs.id
  policy            = data.aws_iam_policy_document.access_from_alb.json
}

