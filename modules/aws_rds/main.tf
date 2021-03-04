####################################
# AWS ELB MODULE
# /!\ Don't change variable values in this file but directly on the bloc module of this Terraform module.
# Last modification date : 09/02/2021
####################################

####################################
# DB INSTANCE
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
####################################
resource "aws_db_instance" "this" {
  # Required
  allocated_storage                     = var.instance_allocated_storage
  engine                                = var.instance_engine
  instance_class                        = var.instance_instance_class
  password                              = var.instance_password
  username                              = var.instance_username

  # Optional
  allow_major_version_upgrade           = var.instance_allow_major_version_upgrade
  apply_immediately                     = true
  auto_minor_version_upgrade            = var.instance_auto_minor_version_upgrade
  availability_zone                     = var.instance_availability_zone
  backup_retention_period               = var.instance_backup_retention_period
  backup_window                         = var.instance_backup_window
  ca_cert_identifier                    = var.instance_ca_cert_identifier
  character_set_name                    = var.instance_character_set_name
  copy_tags_to_snapshot                 = var.instance_copy_tags_to_snapshot
  db_subnet_group_name                  = var.instance_db_subnet_group_name
  delete_automated_backups              = var.instance_delete_automated_backups
  deletion_protection                   = var.instance_deletion_protection
  domain                                = var.instance_domain
  domain_iam_role_name                  = var.instance_domain_iam_role_name
  enabled_cloudwatch_logs_exports       = var.instance_enabled_cloudwatch_logs_exports
  engine_version                        = var.instance_engine_version
  iam_database_authentication_enabled   = var.instance_iam_database_authentication_enabled
  identifier                            = var.instance_identifier #
  identifier_prefix                     = var.instance_identifier_prefix
  iops                                  = var.instance_iops
  kms_key_id                            = var.instance_kms_key_id
  license_model                         = var.instance_license_model
  maintenance_window                    = var.instance_maintenance_window
  max_allocated_storage                 = var.instance_max_allocated_storage
  monitoring_interval                   = var.instance_monitoring_interval
  monitoring_role_arn                   = var.instance_monitoring_role_arn
  multi_az                              = var.instance_multi_az
  name                                  = var.instance_name
  option_group_name                     = var.instance_option_group_name
  parameter_group_name                  = var.instance_parameter_group_name
  port                                  = var.instance_port
  publicly_accessible                   = var.instance_publicly_accessible
  security_group_names                  = var.instance_security_group_names
  skip_final_snapshot                   = true
  snapshot_identifier                   = var.instance_snapshot_identifier
  storage_encrypted                     = var.instance_storage_encrypted
  storage_type                          = var.instance_storage_type
  timezone                              = var.instance_timezone
  vpc_security_group_ids                = var.instance_vpc_security_group_ids
  tags                                  = merge(
    var.instance_tags,
    var.common_tags
  )
  
  depends_on = [ 
    aws_db_subnet_group.this
  ]

}

####################################
# DB SUBNET GROUP
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
####################################
resource "aws_db_subnet_group" "this" {
  name        = var.db_subnet_group_name
  description = var.db_subnet_group_description
  subnet_ids  = var.db_subnet_group_subnet_ids
  tags        = merge(
    var.db_subnet_group_tags,
    var.common_tags
  )
}
