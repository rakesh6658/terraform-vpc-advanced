variable "cidr_block" {
  
}
#optional value
variable "enable_dns_support" {
    default = {}
  
}
#optional value
variable "enable_dns_hostnames" {
  default = {}
}
#optional value
variable "common_tags" {
default = {}  
}
variable "project_name" {
  default = {}
}
#optional value
variable "vpc_tags" {
  default = {}
}
variable "public_subnet_cidr_block" {
    
    type        = list
  description = "limiting to two values"

  validation {
    condition     = length(var.public_subnet_cidr_block) == 2
    error_message = "enter only two values"
  } 
  
}
variable "private_subnet_cidr_block" {
    
    type        = list
  description = "limiting to two values"

  validation {
    condition     = length(var.private_subnet_cidr_block) == 2
    error_message = "enter only two values"
  } 
  
}
variable "database_subnet_cidr_block" {
    
    type        = list
  description = "limiting to two values"

  validation {
    condition     = length(var.database_subnet_cidr_block) == 2
    error_message = "enter only two values"
  } 
  
}


