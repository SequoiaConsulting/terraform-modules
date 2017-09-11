
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
    count                     = 4
    type                      = "ingress"
    from_port                 = "${var.database_port}"
    to_port                   = "${var.database_port}"
    protocol                  = "tcp"
    source_security_group_id  = "${var.allow_inbound_ec2_sg[count.index]}"
    security_group_id         = "${aws_security_group.rds-sg.id}"
 }

 resource "aws_security_group_rule" "allow-inbound-ips-rule" {
   count                     = "${length(var.allow_inbound_ips)}"
   type                      = "ingress"
   from_port                 = "${var.database_port}"
   to_port                   = "${var.database_port}"
   protocol                  = "tcp"
   cidr_blocks               = ["${ var.allow_inbound_ips[count.index]}"]
   security_group_id         = "${aws_security_group.rds-sg.id}"
 }

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
#    engine                    = "${var.engine}"
#    engine_version            = "${var.engine_version}"
#    allocated_storage         = "${var.storage}"
#    storage_type              = "${var.storage_type}"
#    name                      = "${var.db_name}"
#    username                  = "${var.username}"
#    password                  = "${var.password}"
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
    snapshot_identifier       = "${var.snapshot_identifier}"
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
