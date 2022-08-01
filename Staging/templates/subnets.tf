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

######## Subnet for Admin static site
resource "aws_subnet" "private_admin" {
  count                   = length(var.private_admin)
  
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.private_admin,count.index)
  availability_zone       = element(var.azs,count.index)
  map_public_ip_on_launch = false
  tags = {
    Name                  = "PrivateSubnet-Admin-${count.index+1}"
  }
}

######## Subnet for Admin API 
resource "aws_subnet" "private_admin_api" {
  count                   = length(var.private_admin_api)
  
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.private_admin_api,count.index)
  availability_zone       = element(var.azs,count.index)
  map_public_ip_on_launch = false
  tags = {
    Name                  = "PrivateSubnet-Admin-Api-${count.index+1}"
  }
}