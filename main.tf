##################################
# NETWORKS
##################################
module "website_network" {
  source      = "./modules/aws_network"
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
  }

  # AWS SERVICES : VPC
  cidr_block                      = "10.0.0.0/16"
  enable_dns_hostnames            = true
  enable_dns_support              = true
  enable_classiclink              = true
  enable_classiclink_dns_support  = true
  vpc_tags                        = {
    Name = "grimordal-vpc"
  }

  # AWS SERVICES : INTERNET GATEWAY
  igw_tags = {
    Name = "grimordal-igw"
  }

  # AWS SERVICES : ROUTES TABLES
  public_route_table_tags  = {
    Name = "public"
  }
  private_route_table_tags = {
    Name = "private"
  }

  # AWS SERVICES : NAT EIP
  nat_eip_tags = {
    Name = "nat-eip"
  }

  # AWS SERVICES : NAT GATEWAY
  nat_gateway_tags = {
    Name = "nat-gateway"
  }

  # AWS SERVICES : SUBNETS
  azs                 = var.aws_azs
  public_subnets      = var.aws_public_subnets
  public_subnet_tags  = {
    Name = "public"
  }
  private_subnets     = var.aws_private_subnets
  private_subnet_tags = {
    Name = "private"
  }

}

##################################
# SECURITY GROUPS
##################################
module "sg_database" {
  source = "./modules/aws_sg"

  # SECURITY GROUP
  sg_name        = "mysql"
  sg_description = "Allow trafic for MySQL"
  sg_vpc_id      = module.website_network.vpc_id

  # SECURITY GROUP RULES
  ingress = [
    {
      description = "MYSQL Port"
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress  = [
    {
      description = "All outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

module "sg_web" {
  source = "./modules/aws_sg"

  # SECURITY GROUP
  sg_name        = "web"
  sg_description = "Allow http, https and ssh"
  sg_vpc_id      = module.website_network.vpc_id

  # SECURITY GROUP RULES
  ingress = [
    {
      description = "HTTPS from VPC"
      from_port   = var.https_port
      to_port     = var.https_port
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "HTTP from VPC"
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "SSH from VPC"
      from_port   = var.ssh_port
      to_port     = var.ssh_port
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress  = [
    {
      description = "All outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

module "sg_memcached" {
  source = "./modules/aws_sg"

  # SECURITY GROUP
  sg_name        = "memcached"
  sg_description = "Allow trafic for MemCached"
  sg_vpc_id      = module.website_network.vpc_id

  # SECURITY GROUP RULES
  ingress = [
    {
      description = "MemCached Port"
      from_port   = var.memcached_port
      to_port     = var.memcached_port
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress  = [
    {
      description = "All outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

##################################
# DATABASE
##################################
module "website_rds" {
  source      = "./modules/aws_rds"
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
  }

  # INSTANCE
  instance_deletion_protection      = false          # Optional
  instance_engine                   = "mysql"       # Required
  instance_engine_version           = "5.7"         # Optional
  instance_instance_class           = "db.t2.micro" # Required
  instance_identifier               = var.db_name   # Optional
  instance_allocated_storage        = 20            # Required
  instance_name                     = var.db_name               # Optional
  instance_username                 = var.db_username           # Required
  instance_password                 = var.db_password           # Required
  instance_port                     = format("%s", var.db_port) # Optional
  instance_tags                     = {
    Name = "grimordal-db"
  }
  instance_vpc_security_group_ids   = [format("%s", module.sg_database.id)]
  instance_maintenance_window       = "Mon:00:00-Mon:03:00"
  instance_backup_window            = "03:00-06:00"
  instance_backup_retention_period  = 30

  # DB SUBNET GROUP
  db_subnet_group_name              = "grimordal-db-subnet-group"
  instance_db_subnet_group_name     = "grimordal-db-subnet-group"
  db_subnet_group_description       = "Managed by Terraform"
  db_subnet_group_subnet_ids        = module.website_network.private_subnets
  db_subnet_group_tags              = {
    Name = "grimordal-db-subnet-group"
  }

}

##################################
# MEMCACHED
##################################
module "website_memcached" {
  source = "./modules/aws_memcached"

  # PARAMETER GROUP
  parameter_group_name            = "grimordal-parameter-group" # Required unless replication_group_id is provided
  parameter_group_family          = "memcached1.5"              # Required
  parameter_group_description     = "Managed by Terraform"      # Optional
  max_item_size                   = 10485760                    # Required

  # CLUSTER
  cluster_id                      = "grimordal-memcached"                  # Required
  engine                          = "memcached"                            # Required unless replication_group_id is provided
  engine_version                  = "1.5.16"                               # Optional
  maintenance_window              = "mon:03:00-mon:04:00"                  # Optional
  node_type                       = "cache.m4.large"                       # Required
  num_cache_nodes                 = length(var.aws_private_subnets)        # Required unless replication_group_id is provided
  security_group_ids              = [format("%s", module.sg_memcached.id)] # Required unless replication_group_id is provided 
  port                            = var.memcached_port
  preferred_availability_zones    = var.aws_azs
  az_mode                         = "cross-az"
  cluster_subnet_group_name       = "memcached-subnet-group"
  cluster_tags                    = {
    Name = "grimordal-memcached-cluster"
  }

  # ECACHE SUBNET GROUP
  ecache_subnet_group_name        = "memcached-subnet-group"
  ecache_subnet_group_description = "private memcached subnet group"
  ecache_subnet_group_subnet_ids  = module.website_network.private_subnets
}

##################################
# INSTANCES > NODES
##################################
module "website_node_1" {
  source = "./modules/aws_ec2"
  tags   = {
    Terraform   = "true"
    Environment = var.environment,
    Name        = "node1"
  }

  # KEY PAIR
  kp_key_name                     = "privatekey1"

  # EC2 INSTANCE
  ami                             = "ami-08bac620dc84221eb" # Ubuntu Server 20.04 LTS
  instance_type                   = "t2.micro" # Required
  key_name                        = module.website_node_1.key_pair_kp_name
  monitoring                      = true
  vpc_security_group_ids          = [format("%s", module.sg_web.id)]
  subnet_id                       = module.website_network.public_subnets[0]
  associate_public_ip_address     = true

  db_instance_endpoint            = module.website_rds.db_instance_endpoint
  cluster_configuration_endpoint  = module.website_memcached.cluster_configuration_endpoint
}

module "website_node_2" {
  source = "./modules/aws_ec2"
  tags   = {
    Terraform   = "true"
    Environment = var.environment,
    Name        = "node2"
  }

  # KEY PAIR
  kp_key_name                     = "privatekey2"

  # EC2 INSTANCE
  ami                             = "ami-08bac620dc84221eb" # Ubuntu Server 20.04 LTS
  instance_type                   = "t2.micro" # Required
  key_name                        = module.website_node_2.key_pair_kp_name
  monitoring                      = true
  vpc_security_group_ids          = [format("%s", module.sg_web.id)]
  subnet_id                       = module.website_network.public_subnets[1]
  associate_public_ip_address     = true

  db_instance_endpoint            = module.website_rds.db_instance_endpoint
  cluster_configuration_endpoint  = module.website_memcached.cluster_configuration_endpoint
}

module "website_node_3" {
  source = "./modules/aws_ec2"
  tags   = {
    Terraform   = "true"
    Environment = var.environment,
    Name        = "node3"
  }

  # KEY PAIR
  kp_key_name                     = "privatekey3"

  # EC2 INSTANCE
  ami                             = "ami-08bac620dc84221eb" # Ubuntu Server 20.04 LTS
  instance_type                   = "t2.micro" # Required
  key_name                        = module.website_node_3.key_pair_kp_name
  monitoring                      = true
  vpc_security_group_ids          = [format("%s", module.sg_web.id)]
  subnet_id                       = module.website_network.public_subnets[2]
  associate_public_ip_address     = true

  db_instance_endpoint            = module.website_rds.db_instance_endpoint
  cluster_configuration_endpoint  = module.website_memcached.cluster_configuration_endpoint
}


##################################
# S3
##################################
module "website_s3" {
  source = "./modules/aws_s3"

  bucket = "grimordal-cdn" # only lowercase alphanumeric characters and hyphens
  acl    = "public-read"
}

##################################
# CLOUDFRONT
##################################
module "website_cloudfront" {
  source = "./modules/aws_cloudfront"

  # Required
  enabled             = true

  # Optional
  aliases             = null
  comment             = "Grimordal CloudFront"
  default_root_object = null
  http_version        = "http2"
  is_ipv6_enabled     = false
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false
  web_acl_id          = null
  tags                = null

  # Required
  origin = {
    s3_bucket = {
      domain_name = module.website_s3.s3_bucket_regional_domain_name
      origin_id   = module.website_s3.s3_bucket_id
    }
  }

  # Required
  default_cache_behavior = {
    target_origin_id       = module.website_s3.s3_bucket_id
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Required
  viewer_certificate = {
    cloudfront_default_certificate = true
  }

}

##################################
# LOAD BALANCER
##################################
module "website_elb" {
  source = "./modules/aws_elb"
  tags   = {
    Environment = var.environment
  }

  name                        = "grimordal-elb"
  subnets                     = module.website_network.public_subnets
  security_groups             = [format("%s", module.sg_web.id)]
  internal                    = false
  instances                   = [module.website_node_1.id, module.website_node_2.id, module.website_node_3.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  listener                    = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
    /* A BESOIN D'UN CERTIFICAT SSL POUR FONCTIONNER
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
    {
      instance_port     = "443"
      instance_protocol = "HTTPS"
      lb_port           = "443"
      lb_protocol       = "HTTPS"
      ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
    },
    {
      instance_port     = "22"
      instance_protocol = "SSL"
      lb_port           = "22"
      lb_protocol       = "SSL"
    },
    */
  ]
  depends_on                  = [ 
    module.website_node_1,
    module.website_node_2,
    module.website_node_3
   ]
}

##################################
# ROUTE 53
##################################
module "website_route53" {
  source = "./modules/aws_route53"
  zone_name = var.domain
  vpc_id    = module.website_network.vpc_id
  records   = [
    {
      name  = var.domain
      type  = "A"
      alias = {
        name                    = module.website_elb.dns_name
        zone_id                 = module.website_elb.zone_id
        evaluate_target_health  = true
      }
    }
  ]
}
