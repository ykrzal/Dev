################################################
################# Variables ####################
################################################

############### VPC CIRD block #################
variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

################### Tenancy ####################
variable "tenancy" {
  default = "default"
}

############### Private Subnets ################
variable "private" {
	type = list
	default = ["10.10.11.0/24", "10.10.12.0/24"]
}

############### Public Subnets #################
variable "public" {
	type = list
	default = ["10.10.1.0/24", "10.10.2.0/24"]
}

############## Availability zones ###############
variable "azs" {
	type = list
	default = ["us-east-2a", "us-east-2b"]
}
