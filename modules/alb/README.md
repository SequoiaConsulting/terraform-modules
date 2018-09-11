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
