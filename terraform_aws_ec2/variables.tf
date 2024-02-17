variable "region" {}

variable "access_key" {
  description = "my aws_access_key_id"
}

variable "secret_key" {
  description = "my aws_secret_access_key"
}

variable "privateKey" {
  type    = string
  default = "id_rsa"
}

variable "ec2_instance_name" {
  type    = string
  default = "OpenStack-Server-centos8"
}
