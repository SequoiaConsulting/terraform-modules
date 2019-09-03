##########################--EC2 Instance--####################################
resource "aws_instance" "ec2-instance" {
  instance_type          = var.instance_type
  ami                    = var.ami_id
  key_name               = var.key_name
  vpc_security_group_ids = concat([aws_security_group.ec2-instance-sg.id], var.additional_sgs)
  subnet_id              = var.subnet_id
  iam_instance_profile   = var.iam_instance_profile
  user_data              = var.user_data

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = merge(
    var.additional_tags,
    {
      "Name"       = var.instance_name
      "managed-by" = "terraform"
    },
  )
}

resource "aws_security_group_rule" "allow-inbound-sgs-rule" {
  count                    = length(var.allow_inbound_sgs)
  type                     = "ingress"
  from_port                = element(split(",", var.allow_inbound_sgs[count.index]), 0)
  to_port                  = element(split(",", var.allow_inbound_sgs[count.index]), 0)
  protocol                 = "tcp"
  source_security_group_id = trimspace(element(split(",", var.allow_inbound_sgs[count.index]), 1))
  security_group_id        = aws_security_group.ec2-instance-sg.id
}

resource "aws_security_group_rule" "allow-inbound-ips-rule" {
  count             = length(var.allow_inbound_ips)
  type              = "ingress"
  from_port         = element(split(",", var.allow_inbound_ips[count.index]), 0)
  to_port           = element(split(",", var.allow_inbound_ips[count.index]), 0)
  protocol          = "tcp"
  cidr_blocks       = [trimspace(element(split(",", var.allow_inbound_ips[count.index]), 1))]
  security_group_id = aws_security_group.ec2-instance-sg.id
}

############--Security group for EC2 instance--#################################
resource "aws_security_group" "ec2-instance-sg" {
  name   = format("%s-sg", var.instance_name)
  vpc_id = var.vpc_id

  ########################## outbound internet access###########################
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name"       = format("%s-sg", var.instance_name)
    "managed-by" = "terraform"
  }
}
