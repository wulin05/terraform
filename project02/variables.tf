variable "vpc_cidr_block" {
  type = string
}

variable "private_subnet_cidr_block" {
  type = string
}

variable "public_subnet_cidr_block" {
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

variable "image_name" {
  type = string
}