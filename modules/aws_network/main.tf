####################################
# AWS VPC MODULES
# /!\ Don't change variable values in this file but directly on the bloc module of this Terraform module.
# Last modification date : 03/03/2021
####################################

####################################
# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
####################################
resource "aws_vpc" "this" {
  # Required
  cidr_block                       = var.cidr_block # "10.0.0.0/16"

  # Optional
  instance_tenancy                 = var.instance_tenancy # "default"
  enable_dns_support               = var.enable_dns_support # true
  enable_dns_hostnames             = var.enable_dns_hostnames # false
  enable_classiclink               = var.enable_classiclink # false
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support # false
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block # false
  tags                             = merge(
    var.vpc_tags,
    var.common_tags
  )
}

####################################
# INTERNET GATEWAY
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
####################################
resource "aws_internet_gateway" "this" {
  # Required
  vpc_id = aws_vpc.this.id

  # Optional
  tags = merge(
    var.igw_tags,
    var.common_tags
  )

  # Requirements
  depends_on = [
    aws_vpc.this
  ]
}

####################################
# PUBLIC ROUTE TABLE
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
####################################
resource "aws_route_table" "public" {
  # Required
  vpc_id = aws_vpc.this.id

  # Optional
  tags = merge(
    var.public_route_table_tags,
    var.common_tags
  )

  # Requirements
  depends_on = [
    aws_vpc.this
  ]
}

####################################
# PUBLIC ROUTES
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route     
####################################
resource "aws_route" "public_internet_gateway" {
  # Required
  route_table_id         = aws_route_table.public.id

  # Destination
  destination_cidr_block = "0.0.0.0/0"
  # Target
  gateway_id             = aws_internet_gateway.this.id
  timeouts {
    create = "5m"
  }

  # Requirements
  depends_on = [
    aws_vpc.this,
    aws_internet_gateway.this,
    aws_route_table.public
  ]
}

####################################
# PRIVATE ROUTE TABLE
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
####################################
resource "aws_route_table" "private" {
  # Required
  vpc_id = aws_vpc.this.id

  # Optional
  tags = merge(
    var.private_route_table_tags,
    var.common_tags
  )

  # Requirements
  depends_on = [
    aws_vpc.this
  ]

}

####################################
# PUBLIC SUBNET
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet  
####################################
resource "aws_subnet" "public" {
  # availability_zone_id
  # customer_owned_ipv4_pool
  # iov6_cidr_block
  # map_customer_owned_ip_on_launch
  # outpost_arn
  # assign_ipv6_address_on_creation

  count = length(var.public_subnets) > 0  && length(var.public_subnets) >= length(var.azs) ? length(var.public_subnets) : 0

  # Required
  vpc_id     = aws_vpc.this.id
  cidr_block = element(concat(var.public_subnets, [""]), count.index)
  
  # Optional
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch # False
  tags = merge(
    var.public_subnet_tags,
    var.common_tags
  )

  # Requirements
  depends_on = [
    aws_vpc.this
  ]

}

####################################
# PRIVATE SUBNET
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet  
####################################
resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0  && length(var.private_subnets) >= length(var.azs) ? length(var.private_subnets) : 0

  # Required
  vpc_id     = aws_vpc.this.id
  cidr_block = element(concat(var.private_subnets, [""]), count.index)

  # Optional
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = var.private_subnet_map_public_ip_on_launch # False
  tags = merge(
    var.private_subnet_tags,
    var.common_tags
  )

  # Requirements
  depends_on = [
    aws_vpc.this
  ]
}

####################################
# PUBLIC ROUTE TABLE ASSOCIATION
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
####################################
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  
  # Required
  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  
}

####################################
# PRIVATE ROUTE TABLE ASSOCIATION    
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
####################################
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  # Required
  route_table_id = aws_route_table.private.id
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}

####################################
# NAT EIP
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip  
####################################
resource "aws_eip" "this" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  # Optional
  vpc  = true
  tags = merge(
    var.nat_eip_tags,
    var.common_tags
  )

  # Requirements
  depends_on = [
    aws_vpc.this
  ]
}

####################################
# NAT GATEWAY
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
####################################
resource "aws_nat_gateway" "this" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  # Required
  allocation_id = element(aws_eip.this.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  # Optional
  tags = merge(
    var.nat_gateway_tags,
    var.common_tags
  )

  # Requirements
  depends_on = [
    aws_eip.this
  ]
}
