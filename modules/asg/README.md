# AWS ASG Terraform module

Terraform module which creates ASG resources on AWS.

## Usage

```hcl
module "staging_asg"{
      source = "git@github.com:sharath-yml/terraform-modules.git//modules//asg?ref=v0.39"
      asg_name = "demo-backend-staging"
      image_id = "ami-db710fa3"
      instance_type = "t2.medium"
      iam_instance_profile = "${aws_iam_instance_profile.staging-instance-profile.name}"
      security_groups = ["${aws_security_group.people-backend-staging-ec2.id}"]
      key_name = "demo-dev"
      min_size = 1
      max_size = 4
      vpc_zone_identifier = ["subnet-2ac2ae53","subnet-5eaa2315"]
      target_group_arns = ["${module.demo-backend-staging-alb.alb_tg_id[0]}"]
      sns_topic_arn = "arn:aws:sns:us-west-2:827014229206:demo-Backend-notification"
      additional_tags = [
            {
              key = "resource"
              value = "staging_asg-ec2"
              propagate_at_launch = true
            }
          ]
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| asg_name | Name of the Auto Scaling group | string | - | yes |
| image_id | AMI Id | string | - | yes |
| instance_type | Type of the instances | string | - | yes |
| iam_instance_profile | IAM Instance profile name | string | - | yes |
| security_groups |  List of security groups to be attached | list | - | yes |
| key_name |  The key name that should be used for the instance | string | - | yes |
| min_size |  The minimum size of the auto scaling group | string | - | yes |
| max_size |  The maximum size of the auto scaling group | string | - | yes |
| vpc_zone_identifier | The list of the subnet ID's in which instances will create | list | - | yes |
| target_group_arns | The ARN of the Target group | list | - | yes |
| sns_topic_arn | The ARN of the SNS topic | String | - | yes |
| additional_tags | Additional tags of ASG | list | key = "managed-by", value = "terraform", propagate_at_launch = true | no |




## Outputs

| Name | Description |
|------|-------------|
| asg_name | The name of the Auto scaling group. |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

