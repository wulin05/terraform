terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "backup-linwu"
    key = "myapp/state.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  
}

// use module "vpc" which terraform provided to create vpc more simplely: less code
// in the background, subnet,internet gateway,route table that basically be configured.
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.public_subnet_cidr_block]
  private_subnets = [var.private_subnet_cidr_block]

  public_subnet_tags = {
    Name = "${var.env_prefix}_public_subnet01"
  }
  private_subnet_tags = {
    Name = "${var.env_prefix}_private_subnet01"
  }

  // Don't use it casually, especially nat_gateway: fixed at 32$/M + traffic
  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = {
    Name = "${var.env_prefix}_vpc"
  }
}


module "myapp_webserver" {
  source = "./modules/webserver"
  vpc_id = module.vpc.vpc_id
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  acc_security_cidr = var.acc_security_cidr
  instance_type = var.instance_type
  private_key_location = var.private_key_location
  image_name = var.image_name
  // 之前是自建module/subnet,现在是通过上面使用terraform提供的"vpc"模块：terraform-aws-modules/vpc
  subnet_id = module.vpc.public_subnets[0]
}
