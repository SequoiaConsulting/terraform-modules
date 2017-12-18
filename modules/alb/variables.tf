
variable "alb_name"         {}
variable "alb_subnet_ids"   {type = "list"}
variable "vpc_id"           {}
variable "targets"      {type = "list"}
variable "certificate_arn"  {}
variable "ip_address_type"  {}
