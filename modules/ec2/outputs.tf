output "instance_ids" {
  value = "${aws_instance.ec2-instance.*.id}"
}
output "security_groups" {
  value = "${aws_security_group.ec2-instance-sg.*.id}"
}
output "public_ips" {
  value = "${aws_instance.ec2-instance.*.public_ip}"
}
