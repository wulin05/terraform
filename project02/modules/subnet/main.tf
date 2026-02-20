resource "aws_subnet" "myapp_subnet_1" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

// so we use default route table, no need to creating new one
resource "aws_default_route_table" "main_rtb" {
  // 可以通过: terraform state show aws_vpc.myapp-vpc 来查到上面创建的vpc同时会自动创建的默认route table id的字段名：default_route_table_id
  default_route_table_id = var.default_route_table_id
  
  // 注意没有用 route = {}
  route {  
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}
