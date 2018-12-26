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
variable "additional_tags" {
  type = "list"
  default = [
    {
      key = "managed-by"
      value = "terraform"
      propagate_at_launch = true
    }
  ]
}
variable "root_block_device" {
  description = "Customize details about the root block device of the instance"
  type        = "list"
  default     = [
    {
      volume_type = "gp2"
    }
  ]
}
