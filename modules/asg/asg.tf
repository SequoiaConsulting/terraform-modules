resource "aws_launch_configuration" "lc" {
  name                 = "${var.asg_name}-lc-${var.image_id}"
  image_id             = var.image_id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  security_groups      = var.security_groups
  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }
  key_name = var.key_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.asg_name}-asg"
  launch_configuration = aws_launch_configuration.lc.name
  min_size             = var.min_size
  max_size             = var.max_size
  vpc_zone_identifier  = var.vpc_zone_identifier
  target_group_arns    = var.target_group_arns
  health_check_type    = var.health_check_type
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  tags = [
    concat(
      [
        {
          "key"                 = "Name"
          "value"               = "${var.asg_name}-(autoscaled)"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "managed-by"
          "value"               = "terraform"
          "propagate_at_launch" = true
        },
      ],
      var.additional_tags,
    ),
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale-up" {
  name                   = "${var.asg_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale-down" {
  name                   = "${var.asg_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "high-cpu" {
  alarm_name          = "${var.asg_name}-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Autoscaling group High CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
  alarm_name          = "${var.asg_name}-low-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Autoscaling group Low CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-down.arn]
}

resource "aws_autoscaling_notification" "asg-notification" {
  group_names = [
    aws_autoscaling_group.asg.name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
  ]

  topic_arn = var.sns_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "low-healthy-host-count" {
  count               = var.allow_healthy_host_policy
  alarm_name          = "${var.asg_name}-Low-HealthyHostCount"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = var.min_size - 1

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.alb_tg_arn_suffix
  }

  alarm_description = "Trigger an alert when target Group has low healthy hosts count"
  alarm_actions     = [aws_autoscaling_policy.HealthyHostCount-Scaling-Up-policy[0].arn]
}

resource "aws_autoscaling_policy" "HealthyHostCount-Scaling-Up-policy" {
  count                  = var.allow_healthy_host_policy
  name                   = "${var.asg_name}-scale-up-HealthyHostCount"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}
