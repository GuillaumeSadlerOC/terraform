##################################
# AWS
##################################
variable "aws_provider_version" {
  description = "(Required) AWS provider version to use."
  type        = string
  default     = "~> 3.0"
}

variable "aws_default_region" {
  description = "(Required) AWS provider version to use."
  type        = string
  default     = "eu-west-1"
}

variable "aws_azs" {
  description = "(Required) AWS availability zones."
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "aws_public_subnets" {
  description = "(Required) AWS public subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "aws_private_subnets" {
  description = "(Required) AWS private subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "aws_access_key" {
  description = "(Required) AWS access key."
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "(Required) AWS secret key."
  type        = string
  default     = ""
}

##################################
# PROJECT
##################################
variable "environment" {
  description = "(Required) The name of the environment for aws resources tags."
  type        = string
  default     = "prod"
}

variable "http_port" {
  description = "(Required) HTTP port for web security group. Don't forget to check ELB listener."
  type        = number
  default     = 80
}

variable "https_port" {
  description = "(Required) HTTPS port for web security group. Don't forget to check ELB listener."
  type        = number
  default     = 443
}

variable "ssh_port" {
  description = "(Required) SSH port for web security group. Don't forget to check ELB listener."
  type        = number
  default     = 22
}

variable "memcached_port" {
  description = "(Required) Memcached port for web security group and memcached resource."
  type        = number
  default     = 11211
}

variable "domain" {
  description = "(Required) Site domain."
  type        = string
  default     = ""
}

##################################
# DATABASE
##################################
variable "db_port" {
  description = "(Required) Database port for RDS instance and db security group."
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "(Required) Database name required for aws rds instance."
  type        = string
  default     = "defaultdb"
}

variable "db_username" {
  description = "(Required) Database username required for aws rds instance."
  type        = string
  default     = "defaultuser"
}

variable "db_password" {
  description = "(Required) Database password required for aws rds instance."
  type        = string
  default     = "YourPwdShouldBeLongAndSecure!"
}
