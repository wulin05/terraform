variable "vpc_id" {
  type = string
}

variable "env_prefix" {
  type = string
}

variable "public_key_location" {
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

# variable "avail_zone" {
#   type = string
# }

variable "private_key_location" {
  type = string
}

variable "image_name" {
  type = string
}

variable "subnet_id" {
  type = string
}
