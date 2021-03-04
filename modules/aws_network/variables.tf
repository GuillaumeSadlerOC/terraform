####################################
# MODULE     
####################################
variable "vpc_name" {
  description = "Name of the VPC, used in vpc tags"
  type        = string
  default     = "default-vpc"
}

variable "public_subnets" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = null
}

variable "private_subnets" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = null
}

variable "azs" {
  description = "azs"
  type        = list(string)
  default     = null
}

variable "common_tags" {
  description = "(Optional) Common tags for all resources"
  type        = map(string)
  default     = null
}

####################################
# VPC     
####################################
variable "cidr_block" {
  description = "(Required) The CIDR block for the VPC. Default value is a current VPC value."
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  description = "(Optional) A tenancy option for instances launched into the VPC."
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "(Optional) A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "(Optional) A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = false
}

variable "enable_classiclink" {
  # https://docs.aws.amazon.com/fr_fr/AWSEC2/latest/UserGuide/vpc-classiclink.html
  description = "(Optional) A boolean flag to enable/disable ClassicLink for tge VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = false
}

variable "enable_classiclink_dns_support" {
  # https://docs.aws.amazon.com/fr_fr/AWSEC2/latest/UserGuide/vpc-classiclink.html
  description = "(Optional) A boolean flag to enable/disable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic"
  type        = bool
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  description = "(Optional) Requests an Amazon-provided IPv6 CIDR bmock with a /56 prefix length for the VPC."
  type        = bool
  default     = false
}

variable "vpc_tags" {
  description = "(Optional) VPC tags"
  type        = map(string)
  default = {
    Name = "default-vpc"
  }
}

####################################
# INTERNET GATEWAY     
####################################
variable "igw_tags" {
  description = "(Optional) Internet Gateway tags"
  type        = map(string)
  default     = null
}

####################################
# PUBLIC ROUTE TABLE     
####################################
variable "public_route_table_tags" {
  description = "(Optional) Public route table tags"
  type        = map(string)
  default     = null
}

####################################
# PRIVATE ROUTE TABLE     
####################################
variable "private_route_table_tags" {
  description = "(Optional) Private route table tags"
  type        = map(string)
  default     = null
}

####################################
# PUBLIC SUBNET     
####################################
variable "public_subnet_tags" {
  description = "(Optional) Public subnet tags"
  type        = map(string)
  default     = null
}

variable "public_subnet_assign_ipv6_address_on_creation" {
  description = "(Optional) Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address."
  type = bool
  default = false
}

variable "public_subnet_map_public_ip_on_launch" {
  description = "(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address."
  type = bool
  default = false
}

####################################
# PRIVATE SUBNET     
####################################
variable "private_subnet_tags" {
  description = "(Optional) Private subnet tags"
  type        = map(any)
  default     = null
}

variable "private_subnet_assign_ipv6_address_on_creation"{
  description = "(Optional) Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. "
  type = bool
  default = false
}

variable "private_subnet_map_public_ip_on_launch" {
  description = "(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address."
  type = bool
  default = false
}

####################################
# NAT EIP     
####################################
variable "nat_eip_tags" {
  description = "(Optional) NAT EIP tags"
  type        = map(string)
  default     = null
}

####################################
# NAT GATEWAY     
####################################
variable "nat_gateway_tags" {
  description = "(Optional) NAT Gateway tags"
  type        = map(string)
  default     = null
}
