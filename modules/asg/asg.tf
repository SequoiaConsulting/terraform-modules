resource "aws_launch_configuration" "lc" {
  name                        = "${var.asg_name}-lc-${var.image_id}"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  security_groups             = ["${var.security_groups}"]
  key_name                    = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.asg_name}-asg"
  launch_configuration = "${aws_launch_configuration.lc.name}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  vpc_zone_identifier  = ["${var.vpc_zone_identifier}"]
  target_group_arns    = ["${var.target_group_arns}"]
  tags = ["${concat(
    list(
      map("key", "Name", "value", "${var.asg_name}-(autoscaled)", "propagate_at_launch", true),
      map("key", "managed-by", "value", "terraform", "propagate_at_launch", true)
    ),
    var.additional_tags)
  }"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale-up" {
    name = "${var.asg_name}-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_policy" "scale-down" {
    name = "${var.asg_name}-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "high-cpu" {
    alarm_name = "${var.asg_name}-high-cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "3"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "80"

    dimensions {
      AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
    }

    alarm_description = "Autoscaling group High CPU utilization"
    alarm_actions = ["${aws_autoscaling_policy.scale-up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
    alarm_name = "${var.asg_name}-low-cpu-alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "5"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "30"

    dimensions {
      AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
    }

    alarm_description = "Autoscaling group Low CPU utilization"
    alarm_actions = ["${aws_autoscaling_policy.scale-down.arn}"]
}

resource "aws_autoscaling_notification" "asg-notification" {
  group_names = [
    "${aws_autoscaling_group.asg.name}"
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
  ]

  topic_arn = "${var.sns_topic_arn}"
}
