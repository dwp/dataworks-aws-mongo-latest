variable "emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

resource "aws_lambda_function" "dataworks_aws_mongo_latest_emr_launcher" {
  filename      = "${var.emr_launcher_zip["base_path"]}/emr-launcher-${var.emr_launcher_zip["version"]}.zip"
  function_name = "dataworks_aws_mongo_latest_emr_launcher"
  role          = aws_iam_role.dataworks_aws_mongo_latest_emr_launcher_lambda_role.arn
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
      EMR_LAUNCHER_CONFIG_S3_FOLDER = "emr/dataworks_aws_mongo_latest"
      EMR_LAUNCHER_LOG_LEVEL        = "debug"
    }
  }
}

resource "aws_iam_role" "dataworks_aws_mongo_latest_emr_launcher_lambda_role" {
  name               = "dataworks_aws_mongo_latest_emr_launcher_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.dataworks_aws_mongo_latest_emr_launcher_assume_policy.json
}

data "aws_iam_policy_document" "dataworks_aws_mongo_latest_emr_launcher_assume_policy" {
  statement {
    sid     = "dataworks-aws-mongo-latest-EMRLauncherLambdaAssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "dataworks_aws_mongo_latest_emr_launcher_read_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      format("arn:aws:s3:::%s/emr/dataworks_aws_mongo_latest/*", data.terraform_remote_state.common.outputs.config_bucket.id)
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

data "aws_iam_policy_document" "dataworks_aws_mongo_latest_emr_launcher_runjobflow_policy" {
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

data "aws_iam_policy_document" "dataworks_aws_mongo_latest_emr_launcher_pass_role_document" {
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

resource "aws_iam_policy" "dataworks_aws_mongo_latest_emr_launcher_read_s3_policy" {
  name        = "dataworks_aws_mongo_latestReadS3"
  description = "Allow dataworks_aws_mongo_latest to read from S3 bucket"
  policy      = data.aws_iam_policy_document.dataworks_aws_mongo_latest_emr_launcher_read_s3_policy.json
}

resource "aws_iam_policy" "dataworks_aws_mongo_latest_emr_launcher_runjobflow_policy" {
  name        = "dataworks_aws_mongo_latestRunJobFlow"
  description = "Allow dataworks_aws_mongo_latest to run job flow"
  policy      = data.aws_iam_policy_document.dataworks_aws_mongo_latest_emr_launcher_runjobflow_policy.json
}

resource "aws_iam_policy" "dataworks_aws_mongo_latest_emr_launcher_pass_role_policy" {
  name        = "dataworks_aws_mongo_latestPassRole"
  description = "Allow dataworks_aws_mongo_latest to pass role"
  policy      = data.aws_iam_policy_document.dataworks_aws_mongo_latest_emr_launcher_pass_role_document.json
}

resource "aws_iam_role_policy_attachment" "dataworks_aws_mongo_latest_emr_launcher_read_s3_attachment" {
  role       = aws_iam_role.dataworks_aws_mongo_latest_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.dataworks_aws_mongo_latest_emr_launcher_read_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "dataworks_aws_mongo_latest_emr_launcher_runjobflow_attachment" {
  role       = aws_iam_role.dataworks_aws_mongo_latest_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.dataworks_aws_mongo_latest_emr_launcher_runjobflow_policy.arn
}

resource "aws_iam_role_policy_attachment" "dataworks_aws_mongo_latest_emr_launcher_pass_role_attachment" {
  role       = aws_iam_role.dataworks_aws_mongo_latest_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.dataworks_aws_mongo_latest_emr_launcher_pass_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "dataworks_aws_mongo_latest_emr_launcher_policy_execution" {
  role       = aws_iam_role.dataworks_aws_mongo_latest_emr_launcher_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

