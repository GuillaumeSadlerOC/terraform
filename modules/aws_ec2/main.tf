####################################
# AWS EC2 MODULE
# /!\ Don't change variable values in this file but directly on the bloc module of this Terraform module.
# Last modification date : 09/02/2021
####################################

####################################
# EC2 DATA
# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
####################################
data "template_file" "user_data" {
  template  = file("./modules/aws_ec2/scripts/test.sh")
  vars      = {
    db_instance_endpoint            = format("%s", var.db_instance_endpoint)
    cluster_configuration_endpoint  = format("%s", var.cluster_configuration_endpoint)
  }
}

####################################
# KEY PAIR FOR SSH CONNECTION
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
# https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
####################################
resource "tls_private_key" "this" {
  # Generate new private key
  algorithm = "RSA"
}

resource "aws_key_pair" "this" {
  # Generate a new key-pair with above key
  key_name    = var.kp_key_name
  public_key  = tls_private_key.this.public_key_openssh
}

resource "null_resource" "save_key_pair" {
  # Saving Key pair for ssh login
  provisioner "local-exec" {
    command = "echo ${tls_private_key.this.private_key_pem} > ${var.kp_key_name}.pem"
  }
}

####################################
# EC2
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
####################################
resource "aws_instance" "this" {

  ami                                     = var.ami # Required
  associate_public_ip_address             = var.associate_public_ip_address
  # availability_zone                     = var.availability_zone
  # cpu_core_count                        = var.cpu_core_count
  # disable_api_termination               = var.disable_api_termination
  # ebs_optimized                         = var.ebs_optimized
  # get_password_data                     = var.get_password_data
  # hibernation                           = var.hibernation
  # host_id                               = var.host_id
  # iam_instance_profile                  = var.iam_instance_profile
  # instance_initiated_shutdown_behavior  = var.instance_initiated_shutdown_behavior
  instance_type                           = var.instance_type # Required
  # ipv6_address_count                    = var.ipv6_address_count
  # ipv6_addresses                        = var.ipv6_addresses
  key_name                                = var.key_name
  # monitoring                            = var.monitoring
  # placement_group                       = var.placement_group
  # private_ip                            = var.private_ip
  # secondary_private_ips                 = var.secondary_private_ips
  security_groups                         = var.security_groups
  subnet_id                               = var.subnet_id
  # tenancy                               = var.tenancy
  user_data                               = data.template_file.user_data.rendered
  # user_data_base64                      = var.user_data_base64
  # volume_tags                           = var.volume_tags
  vpc_security_group_ids                  = var.vpc_security_group_ids
  tags                                    = var.tags

  # EBS block suppression
  ebs_block_device {
    device_name           = "/dev/sda1"
    delete_on_termination = true
  }

}
