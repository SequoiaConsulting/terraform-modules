######### ALB Security Group ###################################################
resource "aws_security_group" "alb-sg" {
  name   = "${var.alb_name}-sg"
  vpc_id = var.vpc_id

  tags = {
    "Name"       = "${var.alb_name}-sg"
    "managed-by" = "terraform"
  }
}

resource "aws_security_group_rule" "allow_https_ipv4" {
  count = (var.allow_https == true ? 1 : 0)
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "allow_https_ipv6" {
  count = (var.allow_https == true ? 1 : 0)
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "allow_http_ipv4" {
  count = (var.allow_http == true ? 1 : 0)
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "allow_http_ipv6" {
  count = (var.allow_http == true ? 1 : 0)
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.alb-sg.id
}

##################################  ALB Target groups  ##########################
resource "aws_alb_target_group" "alb-tg" {
  count                = length(var.targets)
  name                 = trimspace(element(split(",", var.targets[count.index]), 0))
  port                 = trimspace(element(split(",", var.targets[count.index]), 1))
  protocol             = "HTTP"
  deregistration_delay = 30
  vpc_id               = var.vpc_id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    path                = trimspace(element(split(",", var.targets[count.index]), 2))
    interval            = 10
  }
  tags = {
    "Name"       = trimspace(element(split(",", var.targets[count.index]), 0))
    "managed-by" = "terraform"
  }
}

############################## HTTP Listner for ALB      #######################
resource "aws_alb_listener" "alb-http-listener" {
  count = (var.allow_http == true ? 1 : 0)
  load_balancer_arn             = "${aws_alb.alb.arn}"
  port                          = "80"
  protocol                      = "HTTP"
  default_action {
       target_group_arn         = "${aws_alb_target_group.alb-tg.0.id}"
       type                     = "forward"
  }
}

############################## HTTPS Listner for ALB      ######################
resource "aws_alb_listener" "alb-https-listener" {
  count = (var.allow_https == true ? 1 : 0)
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = var.ssl_policy
  default_action {
    target_group_arn = aws_alb_target_group.alb-tg[0].arn
    type             = "forward"
  }
}

resource "aws_alb" "alb" {
  name                       = var.alb_name
  internal                   = false
  subnets                    = var.alb_subnet_ids
  security_groups            = [aws_security_group.alb-sg.id]
  enable_deletion_protection = false
  ip_address_type            = var.ip_address_type
  access_logs {
    bucket  = var.alb_access_logs_bucket
    prefix  = var.alb_access_logs_prefix
    enabled = var.alb_access_logs_bucket_enabled
  }
  tags = merge(
    var.additional_tags,
    {
      "Name"       = var.alb_name
      "managed-by" = "terraform"
    },
  )
}
