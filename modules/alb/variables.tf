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

variable "lb_ingress_ipv4" {
  type = list(object({
    protocol = string
    from_port = number
    to_port = number
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "lb_ingress_ipv6" {
  type = list(object({
    protocol = string
    from_port = number
    to_port = number
    ipv6_cidr_blocks = list(string)
    description = string
  }))
  default = []
}
