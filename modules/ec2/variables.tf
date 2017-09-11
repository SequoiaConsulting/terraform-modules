# ENVIRONMENT VARIABLES

variable "count"                  {}
variable "instance_type"          {}
variable "ami_id"                 {}
variable "key_name"            {}
variable "subnet_id"              {}
variable "iam_instance_profile"   {default=""}
variable "disk_size"              {}
variable "instance_name"          {}
variable "vpc_id"                 {}
variable "allow_inbound_sgs"      {type="list", default=[]}
variable "inbound_sgs_count"      {default=0}
variable "allow_inbound_ips"      {type="list", default=[]}
variable "additional_tags" {
  type = "map"
  default = {}
}
