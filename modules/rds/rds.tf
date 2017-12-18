
######################Security Group for RDS##################################
resource "aws_security_group" "rds-sg" {
    name                      = "${var.db_sg_name}"
    description               = "RDS Security Group"
    "vpc_id"                  = "${var.vpc_id}"
    tags {
        "Name"                = "${var.identifier}"
        "managed-by"          = "terraform"
    }
 }

#################Inbound Ports allowed for the EC2 Instance SG###############
resource "aws_security_group_rule" "allow_db_access" {
    count                     = 1
    type                      = "ingress"
    from_port                 = "${var.database_port}"
    to_port                   = "${var.database_port}"
    protocol                  = "tcp"
    source_security_group_id  = "${var.allow_inbound_ec2_sg[count.index]}"
    security_group_id         = "${aws_security_group.rds-sg.id}"
 }

/*
 resource "aws_security_group_rule" "allow-inbound-ips-rule" {
   count                     = "${length(var.allow_inbound_ips)}"
   type                      = "ingress"
   from_port                 = "${var.database_port}"
   to_port                   = "${var.database_port}"
   protocol                  = "tcp"
   cidr_blocks               = ["${ var.allow_inbound_ips[count.index]}"]
   security_group_id         = "${aws_security_group.rds-sg.id}"
 }
 */

#####################################Outbound Ports allowed###################
resource "aws_security_group_rule" "allow_all_outbound" {
    type                      = "egress"
    from_port                 = "0"
    to_port                   = "0"
    protocol                  = "-1"
    cidr_blocks               = ["0.0.0.0/0"]
    security_group_id         = "${aws_security_group.rds-sg.id}"
}

#########################   Creating RDS instance   ##########################
resource "aws_db_instance" "db-instance" {
    identifier                = "${var.identifier}"
    engine                    = "${var.engine}"
    engine_version            = "${var.engine_version}"
    allocated_storage         = "${var.storage}"
    storage_type              = "${var.storage_type}"
    name                      = "${var.db_name}"
    username                  = "${var.username}"
    password                  = "${var.password}"
    instance_class            = "${var.instance_class}"
    multi_az                  = "${var.multi_az}"
    port                      = "${var.database_port}"
    apply_immediately         = "${var.apply_immediately}"
    publicly_accessible       = "${var.rds_publicly_accessible}"
    storage_encrypted         = "${var.rds_storage_encrypted}"
    vpc_security_group_ids    = ["${aws_security_group.rds-sg.id}"]
    db_subnet_group_name      = "${var.db_subnet_group_name}"
    parameter_group_name      = "${aws_db_parameter_group.rds-pg.name}"
    option_group_name         = "${aws_db_option_group.rds-og.name}"
    skip_final_snapshot       = "true"
    backup_retention_period   = "${var.backup_retention_period}"
#    snapshot_identifier       = "${var.snapshot_identifier}"
    tags {
      "Name"                  = "${var.identifier}"
      "managed-by"            = "terraform"
    }
}

resource "aws_db_subnet_group" "db-subnet-group" {
    name                      = "${var.db_subnet_group_name}"
    subnet_ids                = ["${var.rds_subnet_ids}"]
    tags {
      "Name"                  = "${var.db_subnet_group_name}"
      "managed-by"            = "terraform"
    }
}

resource "aws_db_parameter_group" "rds-pg" {
    name                      = "${var.identifier}-db-pg"
    family                    = "mysql5.7"
}

resource "aws_db_option_group" "rds-og" {
    name                     = "${var.identifier}-db-og"
    option_group_description = "${var.identifier} Option Group"
    engine_name              = "mysql"
    major_engine_version     = "5.7"
}


#
# CloudWatch resources
#

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${var.identifier}-dbConnections-alarm"
  alarm_description   = "DB server Connections crossing threshod of ${var.alarm_connections_threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "${var.alarm_connections_threshold}"

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.db-instance.id}"
  }

  alarm_actions             = ["${var.sns_topic_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.identifier}-DBServerCPUUtilization-alarm"
  alarm_description   = "DB server CPU utilization crossing threshod of ${var.alarm_cpu_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "${var.alarm_cpu_threshold}"

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.db-instance.id}"
  }

  alarm_actions             = ["${var.sns_topic_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "database_disk_free" {
  alarm_name          = "${var.identifier}-DBServerFreeStorageSpace-alarm"
  alarm_description   = "DB server free storage space less than ${var.alarm_free_disk_threshold} Bytes"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.alarm_free_disk_threshold}"

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.db-instance.id}"
  }

  alarm_actions             = ["${var.sns_topic_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "database_memory_free" {
  alarm_name          = "${var.identifier}-DBServerFreeableMemory-alarm"
  alarm_description   = "DB server freeable memory less than ${var.alarm_free_memory_threshold} Bytes"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.alarm_free_memory_threshold}"

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.db-instance.id}"
  }

  alarm_actions             = ["${var.sns_topic_arn}"]
}
