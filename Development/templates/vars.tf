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
	default = "development-vpc"
}

############### IGW Name (Tag) ##################
variable "igw_name" {
	default = "development-igw"
}

############# NAT GW Name (Tag) #################
variable "natgw_name" {
	default = "development-natgw"
}

############### ALB Name (Tag) ##################
variable "alb_name" {
	default = "development-alb"
}

######## ALB access log bucket name ##############
variable "accesslog_bucket_name" {
	default = "boopos-bucket-access-logs"
}

######## ALB access log bucket TAG ###############
variable "accesslog_bucket_tag" {
	default = "delelopment-boopos-alb-s3"
}

######## Fargate task CPU (Admin) ################
variable "admin_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

######## Fargate task CPU (Admin) ################
variable "admin_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

######## Fargate task image (Admin) ###############
variable "admin_image" {
  description = "Docker image to run in the Admin ECS cluster"
  default     = "nginx:latest"
}

#########  ###############
variable "health_check_path" {
  default = "/"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role Name"
  default = "myEcsAutoScaleRole"
}

variable "admin_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

variable "admin_container_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "admin_ecs_min_instances" {
  default = "1"
}

variable "admin_ecs_max_instances" {
  default = "2"
}

variable "environment" {
  default = "dev"
}

variable "region" {
  default = "us-east-1"
}

variable "replicas" {
  default = "1"
}