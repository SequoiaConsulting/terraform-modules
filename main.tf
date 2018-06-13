module "my-ec2" {
  source = "git@github.com:sharath-yml/terraform-modules.git//modules//ec2?ref=v0.31"
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

resource "aws_route53_record" "web-dev" {
  zone_id = "ZGPZXFJHFRT0"
  name    = "pulse-web-dev.ymedia.in"
  type    = "A"
  ttl     = "300"
  records = ["${module.my-ec2.public_ips[0]}"]
}
