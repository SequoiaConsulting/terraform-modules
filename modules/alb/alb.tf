
######### ALB Security Group ##################################################
resource "aws_security_group" "alb-sg" {
    name                        = "${var.alb_name}-sg"
    vpc_id                      = "${var.vpc_id}"
    ingress {
      from_port                 = 443
      to_port                   = 443
      protocol                  = "tcp"
      cidr_blocks               = ["0.0.0.0/0"]
    }

    ingress {
      from_port                 = 443
      to_port                   = 443
      protocol                  = "tcp"
      ipv6_cidr_blocks          = ["::/0"]
    }

    #################### outbound internet access from anywhere    ############
    egress {
      from_port                 = 0
      to_port                   = 0
      protocol                  = "-1"
      cidr_blocks               = ["0.0.0.0/0"]
    }

    egress {
      from_port                 = 0
      to_port                   = 0
      protocol                  = "-1"
      ipv6_cidr_blocks          = ["::/0"]
    }

      tags {
      "Name"                    = "${var.alb_name}-sg"
      "managed-by"              = "terraform"
   }
}

##################################  ALB Target group  ##########################
resource "aws_alb_target_group" "alb-tg" {
    name                        = "${var.alb_name}-tg"
    port                        = "${var.target_port}"
    protocol                    = "HTTP"
    vpc_id                      = "${var.vpc_id}"
        health_check {
        healthy_threshold       = 2
        unhealthy_threshold     = 2
        timeout                 = 5
        path                    = "/"
        interval                = 10
        }
      tags {
      "Name"                    = "${var.alb_name}-tg"
      "managed-by"              = "terraform"
     }

 }


############################## Listner for ALB      ############################
 resource "aws_alb_listener" "alb-listener" {
   load_balancer_arn          = "${aws_alb.alb.arn}"
   port                       = "443"
   protocol                   = "HTTPS"
   certificate_arn            = "${var.certificate_arn}"

        default_action {
        target_group_arn      = "${aws_alb_target_group.alb-tg.arn}"
        type                  = "forward"
    }
 }

 resource "aws_alb" "alb" {
    name                      = "${var.alb_name}"
    internal                  = false
    subnets                   = ["${var.alb_subnet_ids}"]
    security_groups           = ["${aws_security_group.alb-sg.id}"]
    enable_deletion_protection= false
    ip_address_type           = "${var.ip_address_type}"
    tags {
      "Name"                  = "${var.alb_name}-tg"
      "managed-by"            = "terraform"      
   }
}
