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

variable "acc_security_cidr" {
  type = list(object({
    name = string
    cidr_block = string
  }))
}

variable "instance_type" {
  type = string
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp_subnet_1" {
  vpc_id = aws_vpc.myapp_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

// so we use default route table, no need to creating new one
resource "aws_default_route_table" "main_rtb" {
  // 可以通过: terraform state show aws_vpc.myapp-vpc 来查到上面创建的vpc同时会自动创建的默认route table id的字段名：default_route_table_id
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
  
  // 注意没有用 route = {}
  route {  
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}

// Locate the existing default security group in this VPC, then let Terraform take over it and modify the rules.
// but in real production environment we suggest create new security group to modify the rules.
resource "aws_default_security_group" "default_myapp_sg" {
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.acc_security_cidr[0].cidr_block]
    description = "Library_SSH_Connection"
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.acc_security_cidr[1].cidr_block]
    description = "Home_SSH_Connection"
  }

  // allow any others can access this nginx server port
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
    prefix_list_ids = []  
  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

/* 
// teach by chatgpt --- pro environment use
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}
*/

// dynamic AMI --- teach by video
data "aws_ami" "lastest_amazon_linux_image" {
  // pro evironment strongly dispermit to use.
  most_recent = true 
  owners = [ "amazon" ]

  filter {
    name = "name"
    values = [ "al2023-ami-*-kernel-6.1-x86_64" ]
  }

  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }

  // 不用这个会是多个AMI,这个能够只有一个AMI: al2023-ami-2023.10.20260202.2-kernel-6.1-x86_64
  name_regex = "^al2023-ami-[0-9].*-kernel-6.1-x86_64$" 
}

// To check the data correctly output AMI_ID message
output "aws_ami_id" {
  value = data.aws_ami.lastest_amazon_linux_image.id
  # value = data.aws_ssm_parameter.al2023.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp_server.public_ip 
}

// if you use ssh public key by generated in local, please create this resource.
resource "aws_key_pair" "ssh_public_key" {
  key_name = "local_generate_pub_key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp_server" {
  ami = data.aws_ami.lastest_amazon_linux_image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp_subnet_1.id
  vpc_security_group_ids = [aws_default_security_group.default_myapp_sg.id]
  // availability_zone不用写,因为subnet里面已经有avail_zone的信息了：ap-northeast-1a
  availability_zone = var.avail_zone  // as the reason above, this is not necessary.

  associate_public_ip_address = true
  # key_name = "WSL_AlmaLinux9_terraform"    // this key pair(.pem format) is created in aws plane
  key_name = aws_key_pair.ssh_public_key.key_name   // when create resource "aws_key_pair" "ssh_key", please use this method.

  //一.this is bash command which can be run on the ec2 start...
  # user_data = <<EOF
  #                 #!/bin/bash
  #                 sudo yum update -y && sudo yum install -y docker
  #                 sudo systemctl start docker
  #                 sudo usermod -aG docker ec2-user
  #                 docker run -p 8080:80 nginx
  #             EOF
  //二.also, command is directly write above is not good idea,so:
  # user_data = file("entry-script.sh")
  //三. before excute script,it must use connection key setting to let terraform can connect ec2 after ec2 ready,if network is terrible or delay, it will fail.
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    // note: use this private key to decryption ssh connection
    private_key = file(var.private_key_location)
  }

  provisioner "remote-exec" {
    inline = [ 
      "export ENV=dev",
      "mkdir newidr"
     ]
  }

  tags = {
    Name = "${var.env_prefix}-myapp-server"
  }
}
