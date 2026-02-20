// To check the data correctly output AMI_ID message
output "aws_ami_id" {
  value = data.aws_ami.lastest_amazon_linux_image.id
  # value = data.aws_ssm_parameter.al2023.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp_server.public_ip 
}