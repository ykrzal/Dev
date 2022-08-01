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

########### Private Subnets Admin ###############
variable "private_admin" {
	type = list
	default = ["10.10.13.0/24", "10.10.14.0/24"]
}

########### Public Subnets Admin API ############

variable "private_admin_api" {
	type = list
	default = ["10.10.15.0/24", "10.10.16.0/24"]
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

############### VPC Name (Tag) ##################
variable "vpc_name" {
	default = "development-main-vpc"
}
