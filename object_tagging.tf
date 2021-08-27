# AWS IAM for Cloudwatch event triggers
data "aws_iam_policy_document" "cloudwatch_events_assume_role" {
  statement {
    sid    = "CloudwatchEventsAssumeRolePolicy"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "allow_batch_job_submission" {
  name               = "MongoLatestAllowBatchJobSubmission"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_assume_role.json
  tags = {
    Name = "allow_batch_job_submission"
  }
}

data "aws_iam_policy_document" "allow_batch_job_submission" {
  statement {
    sid    = "AllowBatchJobSubmission"
    effect = "Allow"

    actions = [
      "batch:SubmitJob",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "allow_batch_job_submission" {
  name   = "MongoLatestAllowBatchJobSubmission"
  policy = data.aws_iam_policy_document.allow_batch_job_submission.json

  tags = {
    Name = "allow_batch_job_submission"
  }
}

resource "aws_iam_role_policy_attachment" "allow_batch_job_submission" {
  role       = aws_iam_role.allow_batch_job_submission.name
  policy_arn = aws_iam_policy.allow_batch_job_submission.arn
}

# resource "aws_cloudwatch_event_target" "mongo_latest_success_start_object_tagger" {
#   target_id = "mongo_latest_success"
#   rule      = aws_cloudwatch_event_rule.mongo_latest_success.name
#   arn       = data.terraform_remote_state.aws_s3_object_tagger.outputs.s3_object_tagger_batch.pt_job_queue.arn
#   role_arn  = aws_iam_role.allow_batch_job_submission.arn

#   batch_target {
#     job_definition = data.terraform_remote_state.aws_s3_object_tagger.outputs.s3_object_tagger_batch.job_definition.name
#     job_name       = "mongo-latest-success-cloudwatch-event"
#   }

#   input = "{\"Parameters\": {\"data-s3-prefix\": \"${local.data_classification.data_s3_prefix}\", \"csv-location\": \"s3://${local.data_classification.config_bucket.id}/${local.data_classification.config_prefix}/data_classification.csv\"}}"
# }
