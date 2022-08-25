#####################################################
##################### VPC ###########################
#####################################################
resource "aws_vpc" "main_vpc" {
  cidr_block            = var.vpc_cidr
  instance_tenancy      = var.tenancy
  enable_dns_hostnames  = true
  

  tags = {
    Name                = var.vpc_name
  }
}

# #####################################################
# ############# Enable VPC FlowLog ####################
# #####################################################
# resource "aws_flow_log" "flowlog" {
#   iam_role_arn    = aws_iam_role.flowlogrole.arn
#   log_destination = aws_cloudwatch_log_group.vpc_flowlog.arn
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.main_vpc.id
# }

# resource "aws_cloudwatch_log_group" "vpc_flowlog" {
#   name            = "boopos-vpc-flowlog-${local.account_id}"
# }

# #####################################################
# #############  VPC-peering for HCP ##################
# #####################################################

# resource "aws_vpc" "peer" {  #resource_type.resource_name
#   cidr_block = var.vpc_cidr
# }

data "aws_arn" "peer" {
  arn = aws_vpc.main_vpc.arn
}

resource "hcp_aws_network_peering" "peer" {
  hvn_id              = hcp_hvn.hcp_tf_hvn.hvn_id
  peering_id          = var.peering_id
  peer_vpc_id         = aws_vpc.main_vpc.id
  peer_account_id     = aws_vpc.main_vpc.owner_id
  peer_vpc_region     = data.aws_arn.peer.region
}

resource "hcp_hvn_route" "peer_route" {
  hvn_link         = hcp_hvn.hcp_tf_hvn.self_link
  hvn_route_id     = var.route_id
  destination_cidr = aws_vpc.main_vpc.cidr_block
  target_link      = hcp_aws_network_peering.main_vpc.self_link
}

resource "aws_vpc_peering_connection_accepter" "main_vpc" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}