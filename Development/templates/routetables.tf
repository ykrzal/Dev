#####################################################
############### IGW RT A/B ##########################
######## Route table: attach Internet Gateway #######
#####################################################
resource "aws_route_table" "public_rt" {
  vpc_id             = aws_vpc.main_vpc.id

  route {
    cidr_block       = "0.0.0.0/0"
    gateway_id       = aws_internet_gateway.igw.id
  }

  tags = {
    Name             = "PublicRouteTable"
  }
}

#####################################################
############### NAT RT A/B ##########################
########## Route table: attach Nat Gateway ##########
#####################################################
resource "aws_route_table" "nat_rt" {
  count               = length(var.private)

  vpc_id              = aws_vpc.main_vpc.id

  route {
    cidr_block        = "0.0.0.0/0"
    nat_gateway_id    = element(aws_nat_gateway.natgw.*.id , count.index)

  }
  tags = {
    Name              = "NatRouteTable-${count.index+1}"
  }
}

#####################################################
############## Public SA A/B ########################
######### Public Subnet Association #################
#####################################################
resource "aws_route_table_association" "public" {
  count               = length(var.public)

  subnet_id           = element(aws_subnet.public.*.id,count.index)
  route_table_id      = aws_route_table.public_rt.id
}

#####################################################
################### NAT SA A/B ######################
############ NAT Subnet Association #################
#####################################################
resource "aws_route_table_association" "nat_rt" {
  count               = length(var.private)

  subnet_id           = element(aws_subnet.private.*.id,count.index)
  route_table_id      = element(aws_route_table.nat_rt.*.id,count.index)
}
