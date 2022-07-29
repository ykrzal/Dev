#####################################################
############## Create Internet GW ###################
#####################################################
resource "aws_internet_gateway" "igw" {
  vpc_id        = aws_vpc.main_vpc.id

  tags = {
    Name        = "igw"
  }
}
