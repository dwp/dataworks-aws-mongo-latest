resource "aws_acm_certificate" "dataworks_aws_mongo_latest" {
  certificate_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  domain_name               = "dataworks-aws-mongo-latest.${local.env_prefix[local.environment]}${local.dataworks_domain_name}"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}

data "aws_iam_policy_document" "dataworks_aws_mongo_latest_acm" {
  statement {
    effect = "Allow"

    actions = [
      "acm:ExportCertificate",
    ]

    resources = [
      aws_acm_certificate.dataworks_aws_mongo_latest.arn
    ]
  }
}

resource "aws_iam_policy" "dataworks_aws_mongo_latest_acm" {
  name        = "ACMExport-dataworks-aws-mongo-latest-Cert"
  description = "Allow export of dataworks-aws-mongo-latest certificate"
  policy      = data.aws_iam_policy_document.dataworks_aws_mongo_latest_acm.json
}

data "aws_iam_policy_document" "dataworks_aws_mongo_latest_certificates" {
  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::${local.mgt_certificate_bucket}*",
      "arn:aws:s3:::${local.env_certificate_bucket}/*",
    ]
  }
}

resource "aws_iam_policy" "dataworks_aws_mongo_latest_certificates" {
  name        = "dataworks_aws_mongo_latestGetCertificates"
  description = "Allow read access to the Crown-specific subset of the dataworks_aws_mongo_latest"
  policy      = data.aws_iam_policy_document.dataworks_aws_mongo_latest_certificates.json
}


