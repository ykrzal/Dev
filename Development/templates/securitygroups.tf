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
########### ALB SG Allow_all_traffic ################
#####################################################
resource "aws_security_group" "alb" {
  name               = "alb"
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
    Name             = "ALB-SG"
  }
}

#####################################################
########## Allow_all_traffic_from_ALB ###############
#####################################################
resource "aws_security_group" "allow_all_traffic_from_alb" {
  name               = "allow_all_traffic_from_alb"
  vpc_id             = aws_vpc.main_vpc.id
  description = "allow inbound access from the ALB only"

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name             = "AdminSite-SG"
  }
}

# Traffic to the ECS cluster should only come from the ALB
