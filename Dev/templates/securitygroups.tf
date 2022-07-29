#####################################################
### In this template we will create SG and rules ####
#####################################################


#####################################################
############### Allow_all_local #####################
#####################################################
resource "aws_security_group" "allow_all_local" {
  name               = "allow_all_local"
  vpc_id             = aws_vpc.main_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name             = "allow_all_local"
  }
}

#####################################################
############### Allow_all_traffic ###################
#####################################################
resource "aws_security_group" "allow_all_traffic" {
  name               = "allow_all_traffic"
  vpc_id             = aws_vpc.main_vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name             = "allow_all_traffic"
  }
}

#####################################################
########## Allow_all_traffic_from_ALB ###############
#####################################################
resource "aws_security_group" "allow_all_traffic_from_alb" {
  name               = "allow_all_traffic_from_alb"
  vpc_id             = aws_vpc.main_vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name             = "allow_all_traffic_from_alb"
  }
}
