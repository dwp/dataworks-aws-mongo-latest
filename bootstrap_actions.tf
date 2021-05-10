resource "aws_s3_bucket_object" "metadata_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/dataworks_aws_mongo_latest/metadata.sh"
  content    = file("${path.module}/bootstrap_actions/metadata.sh")
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}

resource "aws_s3_bucket_object" "download_scripts_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks_aws_mongo_latest/download_scripts.sh"
  content = templatefile("${path.module}/bootstrap_actions/download_scripts.sh",
    {
      VERSION                               = local.dataworks_aws_mongo_latest_version[local.environment]
      dataworks_aws_mongo_latest_LOG_LEVEL = local.dataworks_aws_mongo_latest_log_level[local.environment]
      ENVIRONMENT_NAME                      = local.environment
      S3_COMMON_LOGGING_SHELL               = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, data.terraform_remote_state.common.outputs.application_logging_common_file.s3_id)
      S3_LOGGING_SHELL                      = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.logging_script.key)
      scripts_location                      = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, "component/dataworks_aws_mongo_latest")
  })
}

resource "aws_s3_bucket_object" "emr_setup_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks_aws_mongo_latest/emr-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/emr-setup.sh",
    {
      dataworks_aws_mongo_latest_LOG_LEVEL = local.dataworks_aws_mongo_latest_log_level[local.environment]
      aws_default_region                    = "eu-west-2"
      full_proxy                            = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      full_no_proxy                         = local.no_proxy
      acm_cert_arn                          = aws_acm_certificate.dataworks_aws_mongo_latest.arn
      private_key_alias                     = "private_key"
      truststore_aliases                    = join(",", var.truststore_aliases)
      truststore_certs                      = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
      dks_endpoint                          = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
      cwa_metrics_collection_interval       = local.cw_agent_metrics_collection_interval
      cwa_namespace                         = local.cw_agent_namespace
      cwa_log_group_name                    = aws_cloudwatch_log_group.dataworks_aws_mongo_latest.name
      S3_CLOUDWATCH_SHELL                   = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.cloudwatch_sh.key)
      cwa_bootstrap_loggrp_name             = aws_cloudwatch_log_group.dataworks_aws_mongo_latest_cw_bootstrap_loggroup.name
      cwa_steps_loggrp_name                 = aws_cloudwatch_log_group.dataworks_aws_mongo_latest_cw_steps_loggroup.name
      name                                  = local.emr_cluster_name
  })
}

resource "aws_s3_bucket_object" "ssm_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/dataworks_aws_mongo_latest/start_ssm.sh"
  content = file("${path.module}/bootstrap_actions/start_ssm.sh")
}


resource "aws_s3_bucket_object" "logging_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/dataworks_aws_mongo_latest/logging.sh"
  content = file("${path.module}/bootstrap_actions/logging.sh")
}

resource "aws_cloudwatch_log_group" "dataworks_aws_mongo_latest" {
  name              = local.cw_agent_log_group_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "dataworks_aws_mongo_latest_cw_bootstrap_loggroup" {
  name              = local.cw_agent_bootstrap_loggrp_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "dataworks_aws_mongo_latest_cw_steps_loggroup" {
  name              = local.cw_agent_steps_loggrp_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_s3_bucket_object" "cloudwatch_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks_aws_mongo_latest/cloudwatch.sh"
  content = templatefile("${path.module}/bootstrap_actions/cloudwatch.sh",
    {
      emr_release = var.emr_release[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "metrics_setup_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks_aws_mongo_latest/metrics-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/metrics-setup.sh",
    {
      proxy_url         = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      metrics_pom       = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.metrics_pom.key)
      prometheus_config = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.prometheus_config.key)
    }
  )
}

resource "aws_s3_bucket_object" "metrics_pom" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks_aws_mongo_latest/metrics/pom.xml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/pom.xml")
}

resource "aws_s3_bucket_object" "prometheus_config" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks_aws_mongo_latest/metrics/prometheus_config.yml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/prometheus_config.yml")
}
