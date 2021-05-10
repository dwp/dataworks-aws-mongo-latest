resource "aws_cloudwatch_event_rule" "aws_emr_template_repository_failed" {
  name          = "aws_emr_template_repository_failed"
  description   = "Sends failed message to slack when aws_emr_template_repository cluster terminates with errors"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED_WITH_ERRORS"
    ],
    "name": [
      "aws-emr-template-repository"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "aws_emr_template_repository_terminated" {
  name          = "aws_emr_template_repository_terminated"
  description   = "Sends failed message to slack when aws_emr_template_repository cluster terminates by user request"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "aws-emr-template-repository"
    ],
    "stateChangeReason": [
      "{\"code\":\"USER_REQUEST\",\"message\":\"User request\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "aws_emr_template_repository_success" {
  name          = "aws_emr_template_repository_success"
  description   = "checks that all steps complete"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "aws-emr-template-repository"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "aws_emr_template_repository_running" {
  name          = "aws_emr_template_repository_running"
  description   = "checks that aws_emr_template_repository is running"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "RUNNING"
    ],
    "name": [
      "aws-emr-template-repository"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "aws_emr_template_repository_failed" {
  count                     = local.aws_emr_template_repository_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_emr_template_repository_failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster failed with errors"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_emr_template_repository_failed.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "aws_emr_template_repository_failed",
      notification_type = "Error",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "aws_emr_template_repository_terminated" {
  count                     = local.aws_emr_template_repository_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_emr_template_repository_terminated"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster terminated by user request"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_emr_template_repository_terminated.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "aws_emr_template_repository_terminated",
      notification_type = "Information",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "aws_emr_template_repository_success" {
  count                     = local.aws_emr_template_repository_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_emr_template_repository_success"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring aws_emr_template_repository completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_emr_template_repository_success.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "aws_emr_template_repository_success",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "aws_emr_template_repository_running" {
  count                     = local.aws_emr_template_repository_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_emr_template_repository_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring aws_emr_template_repository running"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_emr_template_repository_running.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "aws_emr_template_repository_running",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}
