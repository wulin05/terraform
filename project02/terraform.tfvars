vpc_cidr_block = "10.0.0.0/16"

private_subnet_cidr_block = "10.0.10.0/24"
public_subnet_cidr_block = "10.0.110.0/24"

avail_zone = "ap-northeast-1a"

env_prefix = "dev"

acc_security_cidr= [
    {cidr_block = "153.162.132.190/32", name = "library"},
    {cidr_block = "126.88.204.205/32", name = "home"},
    {cidr_block = "xxx.xxx.xxx.xxx/32", name = "workstation"}
]

instance_type = "t2.nano"

public_key_location = "/home/Admin05/.ssh/id_ed25519.pub"
private_key_location = "/home/Admin05/.ssh/id_ed25519"

image_name = "al2023-ami-*-kernel-6.1-x86_64"