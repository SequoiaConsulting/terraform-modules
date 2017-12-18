output "vpc_id" {
    value = "${aws_vpc.main.id}"
}

output "ec2-subnets" {
    value = "${aws_subnet.private-subnet-ec2.*.id}"
}

output "elasticache-subnets" {
    value = "${aws_subnet.private-subnet-elasticache.*.id}"
}

output "rds-subnets" {
    value = "${aws_subnet.private-subnet-rds.*.id}"
}

output "alb-subnets" {
    value = "${aws_subnet.public-subnet-alb.*.id}"
}
