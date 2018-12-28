
variable "alb_name"         {}
variable "alb_subnet_ids"   {type = "list"}
variable "vpc_id"           {}
variable "targets"          {type = "list"}
variable "certificate_arn"  {}
variable "ip_address_type"  {}
variable "additional_tags"  {type = "map" default = {}}
variable "allow_http"       {default="0"}
variable "ssl_policy"       {default="ELBSecurityPolicy-TLS-1-2-Ext-2018-06"}
variable "alb_access_logs_bucket" {
  default = ""
}
variable "alb_access_logs_prefix" {
  default = ""
}
variable "alb_access_logs_bucket_enabled" {
  default = "false"
}
