data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "mongo_latest" {
  name               = "mongo_latest"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.tags
}

resource "aws_iam_instance_profile" "mongo_latest" {
  name = "mongo_latest"
  role = aws_iam_role.mongo_latest.id
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "mongo_latest_ebs_cmk" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_ebs_cmk_encrypt.arn
}

resource "aws_iam_role_policy_attachment" "mongo_latest_write_parquet" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_write_parquet.arn
}

resource "aws_iam_role_policy_attachment" "mongo_latest_acm" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_acm.arn
}

resource "aws_iam_role_policy_attachment" "mongo_latest_read_write_processed_bucket" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_read_write_processed_bucket.arn
}


data "aws_iam_policy_document" "mongo_latest_write_logs" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
      "s3:PutObject*",

    ]

    resources = [
      "${data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn}/${local.s3_log_prefix}",
    ]
  }
}

resource "aws_iam_policy" "mongo_latest_write_logs" {
  name        = "MongoLatestWriteLogs"
  description = "Allow writing of Mongo Latest logs"
  policy      = data.aws_iam_policy_document.mongo_latest_write_logs.json
}

resource "aws_iam_role_policy_attachment" "mongo_latest_write_logs" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_write_logs.arn
}

data "aws_iam_policy_document" "mongo_latest_read_config" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.config_bucket.arn,
      data.terraform_remote_state.management.outputs.config_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject*",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/*",
      "${data.terraform_remote_state.management.outputs.config_bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.config_bucket_cmk.arn,
      data.terraform_remote_state.management.outputs.config_bucket.cmk_arn,
    ]
  }
}

resource "aws_iam_policy" "mongo_latest_read_config" {
  name        = "MongoLatestReadConfig"
  description = "Allow reading of Mongo Latest config files"
  policy      = data.aws_iam_policy_document.mongo_latest_read_config.json
}

resource "aws_iam_role_policy_attachment" "mongo_latest_read_config" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_read_config.arn
}

data "aws_iam_policy_document" "mongo_latest_read_artefacts" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.management_artefact.outputs.artefact_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.management_artefact.outputs.artefact_bucket.cmk_arn,
    ]
  }
}

resource "aws_iam_policy" "mongo_latest_read_artefacts" {
  name        = "MongoLatestReadArtefacts"
  description = "Allow reading of Mongo Latest software artefacts"
  policy      = data.aws_iam_policy_document.mongo_latest_read_artefacts.json
}

resource "aws_iam_role_policy_attachment" "mongo_latest_read_artefacts" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_read_artefacts.arn
}

data "aws_iam_policy_document" "mongo_latest_write_dynamodb" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "arn:aws:dynamodb:${var.region}:${local.account[local.environment]}:table/${local.data_pipeline_metadata}"
    ]
  }
}

resource "aws_iam_policy" "mongo_latest_write_dynamodb" {
  name        = "MongoLatestDynamoDB"
  description = "Allows read and write access to Mongo Latest's EMRFS DynamoDB table"
  policy      = data.aws_iam_policy_document.mongo_latest_write_dynamodb.json
}

resource "aws_iam_role_policy_attachment" "mongo_latest_dynamodb" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_write_dynamodb.arn
}

data "aws_iam_policy_document" "mongo_latest_metadata_change" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:ModifyInstanceMetadataOptions",
      "ec2:*Tags",
    ]

    resources = [
      "arn:aws:ec2:${var.region}:${local.account[local.environment]}:instance/*",
    ]
  }
}

resource "aws_iam_policy" "mongo_latest_metadata_change" {
  name        = "MongoLatestMetadataOptions"
  description = "Allow editing of Metadata Options"
  policy      = data.aws_iam_policy_document.mongo_latest_metadata_change.json
}

resource "aws_iam_role_policy_attachment" "mongo_latest_metadata_change" {
  role       = aws_iam_role.mongo_latest.name
  policy_arn = aws_iam_policy.mongo_latest_metadata_change.arn
}
