####################################
# AWS ELB MODULE
# /!\ Don't change variable values in this file but directly on the bloc module of this Terraform module.
# Last modification date : 09/02/2021
####################################

####################################
# EC2 DATA
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb
####################################
resource "aws_elb" "this" {

  name                        = var.name
  name_prefix                 = var.name_prefix
  availability_zones          = var.availability_zones
  subnets                     = var.subnets
  internal                    = var.internal
  security_groups             = var.security_groups
  instances                   = var.instances
  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout
  tags                        = var.tags  

  dynamic "listener" {
    for_each = var.listener
    content {
      instance_port      = listener.value.instance_port
      instance_protocol  = listener.value.instance_protocol
      lb_port            = listener.value.lb_port
      lb_protocol        = listener.value.lb_protocol
      ssl_certificate_id = lookup(listener.value, "ssl_certificate_id", null)
    }
  }

  /*
  health_check {
    healthy_threshold   = lookup(var.health_check, "healthy_threshold")
    unhealthy_threshold = lookup(var.health_check, "unhealthy_threshold")
    target              = lookup(var.health_check, "target")
    interval            = lookup(var.health_check, "interval")
    timeout             = lookup(var.health_check, "timeout")
  }
  */
  
}
