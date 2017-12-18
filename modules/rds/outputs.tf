output "rds_endpoint" {
    value = "${aws_db_instance.db-instance.endpoint}"
}
output "rds_address" {
    value = "${aws_db_instance.db-instance.address}"
}
