# ENVIRONMENT VARIABLES
variable "instance_type" {
}

variable "ami_id" {
}

variable "key_name" {
}

variable "subnet_id" {
}

variable "iam_instance_profile" {
  default = ""
}

variable "volume_size" {
  default = "8"
}

variable "volume_type" {
  default = "gp2"
}

variable "instance_name" {
}

variable "vpc_id" {
}

variable "allow_inbound_sgs" {
  type    = list(string)
  default = []
}

variable "allow_inbound_ips" {
  type    = list(string)
  default = []
}

variable "user_data" {
  default = ""
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}

variable "additional_sgs" {
  type    = list(string)
  default = []
}
