resource "aws_cloudwatch_event_rule" "mongo_latest_failed" {
  name          = "mongo_latest_failed"
  description   = "Sends failed message to slack when Mongo Latest cluster terminates with errors"
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
      "mongo-latest"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "mongo_latest_terminated" {
  name          = "mongo_latest_terminated"
  description   = "Sends failed message to slack when Mongo Latest cluster terminates by user request"
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
      "mongo-latest"
    ],
    "stateChangeReason": [
      "{\"code\":\"USER_REQUEST\",\"message\":\"User request\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "mongo_latest_success" {
  name          = "mongo_latest_success"
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
      "mongo-latest"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "mongo_latest_success_with_errors" {
  name          = "mongo_latest_success_with_errors"
  description   = "checks that all steps complete but with failures on non mandatory steps"
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
      "mongo-latest"
    ],
    "stateChangeReason": [
      "{\"code\":\"STEP_FAILURE\",\"message\":\"Steps completed with errors\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "mongo_latest_running" {
  name          = "mongo_latest_running"
  description   = "checks that Mongo Latest is running"
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
      "mongo-latest"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "mongo_latest_failed" {
  count                     = local.mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "mongo_latest_failed"
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
    RuleName = aws_cloudwatch_event_rule.mongo_latest_failed.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "mongo_latest_failed",
      notification_type = "Error",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "mongo_latest_terminated" {
  count                     = local.mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "mongo_latest_terminated"
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
    RuleName = aws_cloudwatch_event_rule.mongo_latest_terminated.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "mongo_latest_terminated",
      notification_type = "Information",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "mongo_latest_success" {
  count                     = local.mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "mongo_latest_success"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring Mongo Latest completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.mongo_latest_success.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "mongo_latest_success",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "mongo_latest_success_with_errors" {
  count                     = local.mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "mongo_latest_success_with_errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring Mongo Latest completion with errors in non-mandatory steps"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.mongo_latest_success_with_errors.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "mongo_latest_success_with_errors",
      notification_type = "Warning",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "mongo_latest_running" {
  count                     = local.mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "mongo_latest_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring Mongo Latest running"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.mongo_latest_running.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "mongo_latest_running",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}
