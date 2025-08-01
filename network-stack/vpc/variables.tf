# Input Variables
# AWS Region
variable "region" {
  description = "Region in which AWS Resources to be created"
  type        = string
}

variable "environment" {
  description = "environment name for common resources"
  type        = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "private_lb_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "private_app_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "private_db_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "private_vpce_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "private_tgw_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "tgw_id" {
  type = string
}
