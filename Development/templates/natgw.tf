#####################################################
#### We will create 2 Elastic IPs and 2 NAT GW ######
#####################################################

resource "aws_eip" "nat" {
  count         = 2

  vpc           = true
}

resource "aws_nat_gateway" "natgw" {
  count         = length(var.private)

  allocation_id = element(aws_eip.nat.*.id , count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name        = "var.natgw_name-${count.index+1}"
  }
}