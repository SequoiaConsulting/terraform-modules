# AWS ALB Terraform module

Terraform module which creates ALB resources on AWS.

## Usage

```hcl
module "Demo-backend-dev-alb"
{
    source = "git@github.com:sharath-yml/terraform-modules.git//modules//alb?ref=v0.35"
    alb_name                  = "demo-backend-dev-alb"
    vpc_id                    = "vpc-60191319"
    alb_subnet_ids            = ["subnet-2ac2ae53", "subnet-5eaa2315"]
    certificate_arn           = "arn:aws:acm:us-west-2:827014229206:certificate/0a573472-aa83-4063-b204-ec1f355286c6"
    ip_address_type           = "dualstack"
    targets = ["backend-dev, 7300,  /health", "backend-integration-tg, 8300, /health"]
}

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|

## Outputs

| Name | Description |
|------|-------------|
| this_db_instance_address | The address of the RDS instance |
| this_db_instance_arn | The ARN of the RDS instance |
| this_db_instance_availability_zone | The availability zone of the RDS instance |
| this_db_instance_endpoint | The connection endpoint |
| this_db_instance_hosted_zone_id | The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record) |
| this_db_instance_id | The RDS instance ID |
| this_db_instance_name | The database name |
| this_db_instance_password | The database password (this password may be old, because Terraform doesn't track it after initial creation) |
| this_db_instance_port | The database port |
| this_db_instance_resource_id | The RDS Resource ID of this instance |
| this_db_instance_status | The RDS instance status |
| this_db_instance_username | The master username for the database |
| this_db_option_group_arn | The ARN of the db option group |
| this_db_option_group_id | DB option group |
| this_db_parameter_group_arn | The ARN of the db parameter group |
| this_db_parameter_group_id | The db parameter group id |
| this_db_subnet_group_arn | The ARN of the db subnet group |
| this_db_subnet_group_id | The db subnet group name |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

