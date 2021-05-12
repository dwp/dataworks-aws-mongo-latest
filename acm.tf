resource "aws_acm_certificate" "mongo_latest" {
  certificate_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  domain_name               = "mongo-latest.${local.env_prefix[local.environment]}${local.dataworks_domain_name}"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}

data "aws_iam_policy_document" "mongo_latest_acm" {
  statement {
    effect = "Allow"

    actions = [
      "acm:ExportCertificate",
    ]

    resources = [
      aws_acm_certificate.mongo_latest.arn
    ]
  }
}

resource "aws_iam_policy" "mongo_latest_acm" {
  name        = "ACMExportMongoLatestCert"
  description = "Allow export of Mongo Latest certificate"
  policy      = data.aws_iam_policy_document.mongo_latest_acm.json
}
