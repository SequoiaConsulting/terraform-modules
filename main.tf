module "my-ec2" {
  source = "git::ssh://git@bitbucket.org/ymedialabs/terraform-modules.git//modules//ec2?ref=v0.21"
  instance_name             = "example"
  aws_region                = "us-west-2"
  ami_id                    = "ami-7707a10f"
  disk_size                 = "8"
  instance_type             = "t2.small"
  key_name                  = "yml-internal-key"
  iam_instance_profile      = "EC2CodeDeployRole"
  vpc_id                    = "vpc-b1267cd7"
  subnet_id                 = "${var.adobe-aem-poc_ec2_subnet_id}"
  inbound_sgs_count         = 0
  allow_inbound_ips         = ["${var.adobe-aem-poc_ec2_ssh_port}, 	0.0.0.0/0",
                                "80, 0.0.0.0/0",
                                "4503, 0.0.0.0/0",
                                "${var.adobe-aem-poc_ec2_tcp_port},  0.0.0.0/0",]

  additional_tags {
  company = "yml"
  for = "Prashant, Guru"
  project = "adobe-aem-poc"
}
}
