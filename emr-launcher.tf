variable "emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

resource "aws_lambda_function" "mongo_latest_emr_launcher" {
  filename      = "${var.emr_launcher_zip["base_path"]}/emr-launcher-${var.emr_launcher_zip["version"]}.zip"
  function_name = "mongo_latest_emr_launcher"
  role          = aws_iam_role.mongo_latest_emr_launcher_lambda_role.arn
  handler       = "emr_launcher.handler.handler"
  runtime       = "python3.7"
  source_code_hash = filebase64sha256(
    format(
      "%s/emr-launcher-%s.zip",
      var.emr_launcher_zip["base_path"],
      var.emr_launcher_zip["version"]
    )
  )
  publish = false
  timeout = 60

  environment {
    variables = {
      EMR_LAUNCHER_CONFIG_S3_BUCKET = data.terraform_remote_state.common.outputs.config_bucket.id
      EMR_LAUNCHER_CONFIG_S3_FOLDER = "emr/mongo_latest"
      EMR_LAUNCHER_LOG_LEVEL        = "debug"
    }
  }
}

resource "aws_cloudwatch_event_rule" "mongo_latest_emr_launcher_schedule" {
  name                = "mongo_latest_emr_launcher_schedule"
  description         = "Triggers Mongo Latest EMR Launcher"
  schedule_expression = format("cron(%s)", local.mongo_latest_emr_lambda_schedule[local.environment])
}

resource "aws_cloudwatch_event_target" "mongo_latest_emr_launcher_target" {
  rule      = aws_cloudwatch_event_rule.mongo_latest_emr_launcher_schedule.name
  target_id = "mongo_latest_emr_launcher_target"
  arn       = aws_lambda_function.mongo_latest_emr_launcher.arn
}

resource "aws_iam_role" "mongo_latest_emr_launcher_lambda_role" {
  name               = "mongo_latest_emr_launcher_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.mongo_latest_emr_launcher_assume_policy.json
}

data "aws_iam_policy_document" "mongo_latest_emr_launcher_assume_policy" {
  statement {
    sid     = "MongoLatestEMRLauncherLambdaAssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "mongo_latest_emr_launcher_read_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      format("arn:aws:s3:::%s/emr/mongo_latest/*", data.terraform_remote_state.common.outputs.config_bucket.id)
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
    ]
  }
}

data "aws_iam_policy_document" "mongo_latest_emr_launcher_runjobflow_policy" {
  statement {
    effect = "Allow"
    actions = [
      "elasticmapreduce:RunJobFlow",
      "elasticmapreduce:AddTags",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "mongo_latest_emr_launcher_pass_role_document" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/*"
    ]
  }
}

resource "aws_iam_policy" "mongo_latest_emr_launcher_read_s3_policy" {
  name        = "MongoLatestReadS3"
  description = "Allow Mongo Latest to read from S3 bucket"
  policy      = data.aws_iam_policy_document.mongo_latest_emr_launcher_read_s3_policy.json
}

resource "aws_iam_policy" "mongo_latest_emr_launcher_runjobflow_policy" {
  name        = "MongoLatestRunJobFlow"
  description = "Allow Mongo Latest to run job flow"
  policy      = data.aws_iam_policy_document.mongo_latest_emr_launcher_runjobflow_policy.json
}

resource "aws_iam_policy" "mongo_latest_emr_launcher_pass_role_policy" {
  name        = "MongoLatestPassRole"
  description = "Allow Mongo Latest to pass role"
  policy      = data.aws_iam_policy_document.mongo_latest_emr_launcher_pass_role_document.json
}

resource "aws_iam_role_policy_attachment" "mongo_latest_emr_launcher_read_s3_attachment" {
  role       = aws_iam_role.mongo_latest_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.mongo_latest_emr_launcher_read_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "mongo_latest_emr_launcher_runjobflow_attachment" {
  role       = aws_iam_role.mongo_latest_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.mongo_latest_emr_launcher_runjobflow_policy.arn
}

resource "aws_iam_role_policy_attachment" "mongo_latest_emr_launcher_pass_role_attachment" {
  role       = aws_iam_role.mongo_latest_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.mongo_latest_emr_launcher_pass_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "mongo_latest_emr_launcher_policy_execution" {
  role       = aws_iam_role.mongo_latest_emr_launcher_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "mongo_latest_emr_launcher_getsecrets" {
  name        = "MongoLatestGetSecrets"
  description = "Allow Mongo Latest Lambda function to get secrets"
  policy      = data.aws_iam_policy_document.mongo_latest_emr_launcher_getsecrets.json
}

data "aws_iam_policy_document" "mongo_latest_emr_launcher_getsecrets" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.terraform_remote_state.internal_compute.outputs.metadata_store_users.mongo_latest_writer.secret_arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "mongo_latest_emr_launcher_getsecrets" {
  role       = aws_iam_role.mongo_latest_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.mongo_latest_emr_launcher_getsecrets.arn
}

resource "aws_sns_topic_subscription" "mongo_latest_trigger_sns" {
  topic_arn = aws_sns_topic.mongo_latest_cw_trigger_sns.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.mongo_latest_emr_launcher.arn
}

resource "aws_lambda_permission" "mongo_latest_emr_launcher_subscription" {
  statement_id  = "CWTriggerMongoLatestSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mongo_latest_emr_launcher.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.mongo_latest_cw_trigger_sns.arn
}
