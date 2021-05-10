resource "aws_cloudwatch_event_rule" "dataworks_aws_mongo_latest_failed" {
  name          = "dataworks_aws_mongo_latest_failed"
  description   = "Sends failed message to slack when dataworks_aws_mongo_latest cluster terminates with errors"
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
      "dataworks-aws-mongo-latest"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "dataworks_aws_mongo_latest_terminated" {
  name          = "dataworks_aws_mongo_latest_terminated"
  description   = "Sends failed message to slack when dataworks_aws_mongo_latest cluster terminates by user request"
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
      "dataworks-aws-mongo-latest"
    ],
    "stateChangeReason": [
      "{\"code\":\"USER_REQUEST\",\"message\":\"User request\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "dataworks_aws_mongo_latest_success" {
  name          = "dataworks_aws_mongo_latest_success"
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
      "dataworks-aws-mongo-latest"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "dataworks_aws_mongo_latest_running" {
  name          = "dataworks_aws_mongo_latest_running"
  description   = "checks that dataworks_aws_mongo_latest is running"
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
      "dataworks-aws-mongo-latest"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "dataworks_aws_mongo_latest_failed" {
  count                     = local.dataworks_aws_mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "dataworks_aws_mongo_latest_failed"
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
    RuleName = aws_cloudwatch_event_rule.dataworks_aws_mongo_latest_failed.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "dataworks_aws_mongo_latest_failed",
      notification_type = "Error",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "dataworks_aws_mongo_latest_terminated" {
  count                     = local.dataworks_aws_mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "dataworks_aws_mongo_latest_terminated"
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
    RuleName = aws_cloudwatch_event_rule.dataworks_aws_mongo_latest_terminated.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "dataworks_aws_mongo_latest_terminated",
      notification_type = "Information",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "dataworks_aws_mongo_latest_success" {
  count                     = local.dataworks_aws_mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "dataworks_aws_mongo_latest_success"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring dataworks_aws_mongo_latest completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.dataworks_aws_mongo_latest_success.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "dataworks_aws_mongo_latest_success",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "dataworks_aws_mongo_latest_running" {
  count                     = local.dataworks_aws_mongo_latest_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "dataworks_aws_mongo_latest_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring dataworks_aws_mongo_latest running"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.dataworks_aws_mongo_latest_running.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "dataworks_aws_mongo_latest_running",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}
