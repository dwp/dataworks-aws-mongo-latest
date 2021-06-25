resource "aws_sns_topic" "mongo_latest_cw_trigger_sns" {
  name = "mongo_latest_cw_trigger_sns"

  tags = merge(
    local.common_tags,
    {
      "Name" = "mongo_latest_cw_trigger_sns"
    },
  )
}

output "mongo_latest_cw_trigger_sns_topic" {
  value = aws_sns_topic.mongo_latest_cw_trigger_sns
}
