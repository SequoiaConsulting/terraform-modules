output "instance_id" {
  value = "${aws_instance.ec2-instance.id}"
}
output "security_group" {
  value = "${aws_security_group.ec2-instance-sg.id}"
}
output "instance_public_ip_output" {
  value = "${aws_instance.ec2-instance.public_ip}"
}
