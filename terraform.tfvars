aws_provider_version    = "~> 3.0"
aws_default_region      = "eu-west-1"
aws_azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
aws_public_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
aws_private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
aws_access_key          = ""
aws_secret_key          = ""

environment             = "prod"
http_port               = 80
https_port              = 443
ssh_port                = 22
memcached_port          = 11211
domain                  = "grimordal.net"

db_port                 = 3306
db_name                 = "defaultdb"
db_username             = "defaultuser"
db_password             = "YourPwdShouldBeLongAndSecure!"