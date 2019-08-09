variable "alb_name" {
  type = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "targets" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "ip_address_type" {
  type = string
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}

variable "allow_http" {
  type = bool
  default = false
}

variable "allow_https" {
  type = bool
  default = true
}

variable "ssl_policy" {
  type = string
  default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "alb_access_logs_bucket" {
  type = string
  default = ""
}

variable "alb_access_logs_prefix" {
  type = string
  default = ""
}

variable "alb_access_logs_bucket_enabled" {
  type = bool
  default = false
}
