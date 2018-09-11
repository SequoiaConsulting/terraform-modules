#Terraform modules

Recommended Terraform Version: v0.11.1

Consists of modules for:
 * VPC setup
 * EC2 instances coupled with security groups.
 * RDS instances coupled with it's security group.
 * ALB (Application load balancer coupled with it's security group)
 * ASG (Auto scaling groups coupled with launch configs)

Updates:
v0.35 : Included option to associate additional security group for EC2 instances through additional_sgs parameter.
