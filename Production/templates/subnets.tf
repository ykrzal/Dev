####################################################
######## In this template we will Subnets ##########
####################################################

####################################################
################## Public subnets ##################
####################################################

resource "aws_subnet" "public" {
  count                   = length(var.public)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.public,count.index)
  availability_zone       = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name                  = "PublicSubnet-${count.index+1}"
  }
}

#####################################################
################## Private subnets ##################
#####################################################

resource "aws_subnet" "private" {
  count                   = length(var.private)
  
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.private,count.index)
  availability_zone       = element(var.azs,count.index)
  map_public_ip_on_launch = false
  tags = {
    Name                  = "PrivateSubnet-${count.index+1}"
  }
}
