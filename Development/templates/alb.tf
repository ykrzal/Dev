################################################################
######################### ALB ##################################
######## We will create ALB with Deletion Protection   #########
################################################################

resource "aws_alb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.*.id[0], aws_subnet.public.*.id[1]]

  enable_deletion_protection = true

  access_logs {
    bucket            = "${var.accesslog_bucket_name}-${local.account_id}"
    prefix            = "bucket_access_logs"
    enabled           = true
  }

  tags = {
    Environment       = var.accesslog_bucket_tag
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
    bucket          = "${var.accesslog_bucket_name}-${local.account_id}"
    #force_destroy   = false
    force_destroy   = true
}

resource "aws_s3_bucket_policy" "bucket_access_logs_policy" {
  bucket            = aws_s3_bucket.bucket_access_logs.id
  policy            = data.aws_iam_policy_document.access_from_alb.json
}

#################################################################
############## ALB Target group and listener ####################
#################################################################
###### Admin Blue env TG
resource "aws_alb_target_group" "admin" {
  name        = "admin-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

######## Admin Green env TG 
resource "aws_alb_target_group" "admin_green" {
  name        = "admin-target-group-green"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "admin_site" {
  load_balancer_arn = aws_alb.alb.id
  port              = var.admin_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.admin.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "admin_site_green" {
  load_balancer_arn = aws_alb.alb.id
  port              = var.admin_port_green
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.admin_green.id
    type             = "forward"
  }
}