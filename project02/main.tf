provider "aws" {
  
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_block" {
  type = string
}

variable "avail_zone" {
  type = string
}

variable "env_prefix" {
  type = string
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# // That create new route table for using, not use default table default creating by system...
# resource "aws_route_table" "myapp-route-table" {
#   vpc_id = aws_vpc.myapp-vpc.id
#   route {  // 注意没有用 route = {}
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp_igw.id
#   }
#   tags = {
#     Name = "${var.env_prefix}-rtb"
#   }
# }

// so we use default route table, not creating new one
resource "aws_default_route_table" "default_rtb" {
  // 可以通过: terraform state show aws_vpc.myapp-vpc 来查到上面创建的vpc同时会自动创建的默认route table id的字段名：default_route_table_id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  
  route {  // 注意没有用 route = {}
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name = "${var.env_prefix}-default-rtb"
  }
}

resource "aws_route_table_association" "a_rtb_subnet" {
  route_table_id = aws_route_table.myapp-route-table.id
  subnet_id = aws_subnet.myapp-subnet-1.id
}
