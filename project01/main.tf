provider "aws" {
  region = "ap-northeast-1"  // 可以不写,因为aws configure配置好了,文件是在~/.aws目录下
}

// 自定义参数
// 还有一种方式： export TF_VAR_自定义参数名=参数值,然后就可以在这里面直接定义使用了。
// 比如export TF_VAR_vpc_cidr_block="10.1.0.0/16", 现在这个vpc_cidr_block在这定义使用就有值了。
variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_blocks" {
  description = "vpc and subnet cidr block"
  // default: 如果.tfvars文件中没有相关定义值,那么使用default定义值
  type = list(object({
    name = string
    cidr_block = string
  }))
}

variable "environment" {
  description = "environment definitions"
  type = map(object({
    name = string
  }))
}
variable "current_environment" {
  description = "which environment to use"
  type = string
}

resource "aws_vpc" "development" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Tokyo-${var.environment[var.current_environment].name}-vpc"
  }
}

data "aws_availability_zones" "az" {}

resource "aws_subnet" "dev_subnet" {
  count = length(data.aws_availability_zones.az.names)

  vpc_id = aws_vpc.development.id
  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block = var.subnet_cidr_blocks[count.index].cidr_block
  tags = {
    Name = "${var.environment[var.current_environment].name}-subnet${count.index + 1}"
  }
}

output "azs" {
  value = data.aws_availability_zones.az.names
}
