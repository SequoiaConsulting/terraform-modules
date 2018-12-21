# AWS EC2 Terraform module

Terraform module which creates EC2 resources on AWS.

## Usage

```hcl
module "demo-backend-dev-ec2" {
  source = "git@github.com:sharath-yml/terraform-modules.git//modules//ec2?ref=v0.39"
  subnet_id = "subnet-2ac2ae53"
  vpc_id = "vpc-60191319"
  instance_name         = "demo-backend-dev"
  ami_id                = "ami-db710fa3"
  instance_type         = "t2.small"
  key_name              = "demo-dev"
  allow_inbound_ips     = ["22, 0.0.0.0/0"]
  iam_instance_profile  = "${aws_iam_instance_profile.dev-instance-profile.name}"
  inbound_sgs_count     = 2
  allow_inbound_sgs         = [ "7300, ${module.backend-dev-alb.alb_sg_id}",
                                "8300, ${module.backend-dev-alb.alb_sg_id}"]
  volume_size           = 8
  additional_tags {
    for = "Chip"
    project = "demo-backend"
    demo-backend-dev = "v1"
    demo-backend-integration = "v1"
    managed-by = "terraform"
  }
  user_data = "${file("dev-user-data.sh")}"
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| count | The number of EC2 instances to be created | string | 1 | no |
| instance_type | The type of the instance to be created | string | - | yes |
| ami_id | AMI ID of the instance | string | - | yes |
| key_name | Key of the instance | string | - | yes |
| subnet_id |  Id of the subnet in which EC2 will be created | string | - | yes |
| iam_instance_profile |  IAM instance profile name | string | "" | no |
| volume_size | disk/EBS volume size | string | 8 | no |
| volume_type | disk/EBS volume type | string | gp2 | no |
| instance_name | Name of the instance  | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| allow_inbound_sgs | Security groups ID from which the instance is accessible.Input should be port no , security group ID | list | [ ] | no |
| inbound_sgs_count | Count of the security group in allow_inbound_sgs list | string | 0 | no |
| allow_inbound_ips | List of whitelist IP's | list | [] | no |
| user_data | Name of the file containing user data | string | "" | no |
| additional_tags | Additional tags for the instance | map | { } | no |
| additional_sgs | Additional security groups for the instance | list | [ ] | no |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | The ID of the instance. |
| security_groups | The Security group ID of the instance. |
| public_ips | The Public IP of the instance. |
