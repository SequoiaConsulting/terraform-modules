variable "asg_name"             {}
variable "image_id"             {}
variable "instance_type"        {}
variable "iam_instance_profile" {}
variable "security_groups"      {type = "list"}
variable "key_name"             {}
variable "min_size"             {}
variable "max_size"             {}
variable "vpc_zone_identifier"  {type = "list"}
variable "target_group_arns"    {type = "list"}
variable "sns_topic_arn"        {}
