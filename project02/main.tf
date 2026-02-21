terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "myapp-bucket"
    key = "myapp/state.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp_subnet" {
  source = "./modules/subnet"  // ./表示跟当前文件main.tf同级
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp_vpc.id
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
}

module "myapp_webserver" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp_vpc.id
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  acc_security_cidr = var.acc_security_cidr
  instance_type = var.instance_type
  private_key_location = var.private_key_location
  image_name = var.image_name
  // 不能在子模块直接调用另外一个子模块的output.tf的参数,只能通过主main来传递
  subnet_id = module.myapp_subnet.subnet_id
}
