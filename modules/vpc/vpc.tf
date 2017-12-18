resource "aws_vpc" "main" {
    cidr_block                        = "${var.vpc_cidr_block}"
    enable_dns_hostnames              = true
    enable_dns_support                = true
    assign_generated_ipv6_cidr_block  = true

    tags {
        "Name"                        = "${var.vpc_name}"
        "managed-by"                  = "terraform"
    }
}

resource "aws_internet_gateway" "main-ig" {
    vpc_id                            = "${aws_vpc.main.id}"
    tags {
      "Name"                          = "${var.vpc_name}-ig"
      "managed-by"                    = "terraform"
    }
}

resource "aws_nat_gateway" "nat-gateway" {
    allocation_id                     = "${aws_eip.nat-eip.id}"
    subnet_id                         = "${element(aws_subnet.public-subnet-alb.*.id, count.index)}"
    depends_on                        = ["aws_internet_gateway.main-ig", "aws_eip.nat-eip"]
}

resource "aws_egress_only_internet_gateway" "egress-gateway" {
  vpc_id                              = "${aws_vpc.main.id}"
}

resource "aws_eip" "nat-eip" {
    vpc= true
}

##############Subnet in each availablity zone for EC2 instances.###############
resource "aws_subnet" "private-subnet-ec2" {
    vpc_id                            = "${aws_vpc.main.id}"
    count                             = "${length(var.azs[var.region])}"
    cidr_block                        = "${cidrsubnet(var.vpc_cidr_block, 8, count.index)}"
    availability_zone                 = "${element(var.azs[var.region], count.index)}"
    map_public_ip_on_launch           = false
    ipv6_cidr_block                   = "${cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)}"
    assign_ipv6_address_on_creation   = true

    tags {
        "Name"                        = "${var.vpc_name}-ec2-subnet-${element(var.azs[var.region],count.index)}"
        "managed-by"                  = "terraform"
    }
}

########Route table for EC2-Subnet for outbound through NAT#####################
resource "aws_route_table" "ec2-rt" {
    vpc_id                            = "${aws_vpc.main.id}"
    route {
      cidr_block                      = "0.0.0.0/0"
      nat_gateway_id                  = "${aws_nat_gateway.nat-gateway.id}"
    }
    route {
      ipv6_cidr_block = "::/0"
      egress_only_gateway_id = "${aws_egress_only_internet_gateway.egress-gateway.id}"
    }
    tags {
      "Name"                          = "${var.vpc_name}-ec2-route-table-NAT"
      "managed-by"                    = "terraform"
    }
}

resource "aws_route_table_association" "ec2-rt-association" {
    count                             = "${length(var.azs[var.region])}"
    subnet_id                         = "${element(aws_subnet.private-subnet-ec2.*.id, count.index)}"
    route_table_id                    = "${element(aws_route_table.ec2-rt.*.id, count.index)}"
}

######################--RDS Subnet--############################################
resource "aws_subnet" "private-subnet-rds" {
    vpc_id                            = "${aws_vpc.main.id}"
    count                             = "${length(var.azs[var.region])}"
    cidr_block                        = "${cidrsubnet(var.vpc_cidr_block, 8, count.index + 3)}"
    availability_zone                 = "${element(var.azs[var.region], count.index)}"
    map_public_ip_on_launch           = false
    ipv6_cidr_block                   = "${cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index + 3)}"
    assign_ipv6_address_on_creation   = true
    tags {
        Name                          = "${var.vpc_name}-rds-subnet-${element(var.azs[var.region],count.index)}"
        "managed-by"                  = "terraform"
    }
}

resource "aws_route_table" "rds-rt" {
    vpc_id                            = "${aws_vpc.main.id}"

    tags {
      Name                            = "${var.vpc_name}-rds-route-table"
      "managed-by"                    = "terraform"
    }
}

resource "aws_route_table_association" "rds-rt-association" {
    count                             = "${length(var.azs[var.region])}"
    subnet_id                         = "${element(aws_subnet.private-subnet-rds.*.id, count.index)}"
    route_table_id                    = "${element(aws_route_table.rds-rt.*.id, count.index)}"
}

################--ALB subnet--##################################################
resource "aws_subnet" "public-subnet-alb" {
    vpc_id                            = "${aws_vpc.main.id}"
    count                             = "${length(var.azs[var.region])}"
    cidr_block                        = "${cidrsubnet(var.vpc_cidr_block, 8, count.index + 6)}"
    availability_zone                 = "${element(var.azs[var.region], count.index)}"
    map_public_ip_on_launch           = false
    ipv6_cidr_block                   = "${cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index + 6)}"
    map_public_ip_on_launch           = true
    assign_ipv6_address_on_creation   = true
    tags {
        "Name"                        = "${var.vpc_name}-alb-subnet-${element(var.azs[var.region],count.index)}"
        "managed-by"                  = "terraform"
    }
}

resource "aws_route_table" "alb-rt" {
    vpc_id                            = "${aws_vpc.main.id}"
    route {
      cidr_block                      = "0.0.0.0/0"
      gateway_id                      = "${aws_internet_gateway.main-ig.id}"
    }
    route {
      ipv6_cidr_block = "::/0"
      gateway_id                      = "${aws_internet_gateway.main-ig.id}"
    }
    tags {
      "Name"                          = "${var.vpc_name}-alb-route-table-igw"
      "managed-by"                    = "terraform"
    }
}

resource "aws_route_table_association" "alb-rt-association" {
    count                             = "${length(var.azs[var.region])}"
    subnet_id                         = "${element(aws_subnet.public-subnet-alb.*.id, count.index)}"
    route_table_id                    = "${element(aws_route_table.alb-rt.*.id, count.index)}"
}


##############Subnet in each availablity zone for Redis cache instances.########
resource "aws_subnet" "private-subnet-elasticache" {
    vpc_id                            = "${aws_vpc.main.id}"
    count                             = "${length(var.azs[var.region])}"
    cidr_block                        = "${cidrsubnet(var.vpc_cidr_block, 8, count.index + 9)}"
    availability_zone                 = "${element(var.azs[var.region], count.index)}"
    map_public_ip_on_launch           = false
    ipv6_cidr_block                   = "${cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index  + 9)}"
    assign_ipv6_address_on_creation   = true

    tags {
        "Name"                        = "${var.vpc_name}-elasticache-subnet-${element(var.azs[var.region],count.index)}"
        "managed-by"                  = "terraform"
    }
}
