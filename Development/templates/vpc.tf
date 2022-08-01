#####################################################
##################### VPC ###########################
#####################################################
resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.tenancy

  tags = {
    Name           = "aws_vpc.vpc_name"
  }
}

#####################################################
############# Enable VPC FlowLog ####################
#####################################################
resource "aws_flow_log" "flowlog" {
  iam_role_arn    = aws_iam_role.flowlogrole.arn
  log_destination = aws_cloudwatch_log_group.vpc_flowlog.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main_vpc.id
}

resource "aws_cloudwatch_log_group" "vpc_flowlog" {
  name            = "boopos-vpc-flowlog-${local.account_id}"
}
