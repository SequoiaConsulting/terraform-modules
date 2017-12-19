module "my-ec2" {
  source = "git::ssh://git@bitbucket.org/ymedialabs/terraform-modules.git//modules//ec2?ref=dev"
  instance_name             = "example"
  ami_id                    = "ami-7707a10f"
  instance_type             = "t2.small"
  key_name                  = "yml-internal-key"
  allow_inbound_ips         = ["80, 0.0.0.0/0"]

  additional_tags {
  company = "yml"
  for = "Nobody"
  project = "test"
}
}
