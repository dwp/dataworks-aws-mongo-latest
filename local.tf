locals {

  emr_cluster_name = "mongo-latest"

  common_emr_tags = merge(
    local.common_tags,
    {
      for-use-with-amazon-emr-managed-policies = "true"
    },
  )

  common_tags = {
    Environment  = local.environment
    Application  = local.emr_cluster_name
    CreatedBy    = "terraform"
    Owner        = "dataworks platform"
    Persistence  = "Ignore"
    AutoShutdown = "False"
  }

  env_certificate_bucket = "dw-${local.environment}-public-certificates"
  dks_endpoint           = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]

  crypto_workspace = {
    management-dev = "management-dev"
    management     = "management"
  }

  management_workspace = {
    management-dev = "default"
    management     = "management"
  }

  management_account = {
    development = "management-dev"
    qa          = "management-dev"
    integration = "management-dev"
    preprod     = "management"
    production  = "management"
  }

  log_level = {
    development = "DEBUG"
    qa          = "DEBUG"
    integration = "DEBUG"
    preprod     = "INFO"
    production  = "INFO"
  }

  amazon_region_domain = "${data.aws_region.current.name}.amazonaws.com"
  endpoint_services    = ["dynamodb", "ec2", "ec2messages", "glue", "kms", "logs", "monitoring", ".s3", "s3", "secretsmanager", "ssm", "ssmmessages"]
  no_proxy             = "169.254.169.254,${join(",", formatlist("%s.%s", local.endpoint_services, local.amazon_region_domain))},${local.mongo_latest_pushgateway_hostname}"

  decryption_jar_s3_location = "s3://${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id}/emr-encryption-materials-provider/encryption-materials-provider-all.jar"
  decryption_jar_class       = "uk.gov.dwp.dataworks.dks.encryptionmaterialsprovider.DKSEncryptionMaterialsProvider"

  ebs_emrfs_em = {
    EncryptionConfiguration = {
      EnableInTransitEncryption = false
      EnableAtRestEncryption    = true
      AtRestEncryptionConfiguration = {

        S3EncryptionConfiguration = {
          EncryptionMode             = "CSE-Custom"
          S3Object                   = local.decryption_jar_s3_location
          EncryptionKeyProviderClass = local.decryption_jar_class
        }
        LocalDiskEncryptionConfiguration = {
          EnableEbsEncryption       = true
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                 = aws_kms_key.mongo_latest_ebs_cmk.arn
        }
      }
    }
  }

  keep_cluster_alive = {
    development = true
    qa          = false
    integration = false
    preprod     = false
    production  = false
  }

  step_fail_action = {
    development = "CONTINUE"
    qa          = "TERMINATE_CLUSTER"
    integration = "TERMINATE_CLUSTER"
    preprod     = "TERMINATE_CLUSTER"
    production  = "TERMINATE_CLUSTER"
  }

  cw_agent_namespace                   = "/app/mongo_latest"
  cw_agent_log_group_name              = "/app/mongo_latest"
  cw_agent_bootstrap_loggrp_name       = "/app/mongo_latest/bootstrap_actions"
  cw_agent_steps_loggrp_name           = "/app/mongo_latest/step_logs"
  cw_agent_yarnspark_loggrp_name       = "/app/mongo_latest/yarn-spark_logs"
  cw_agent_tests_loggrp_name           = "/app/mongo_latest/tests_logs"
  cw_agent_metrics_collection_interval = 60

  s3_log_prefix = "emr/mongo_latest"

  data_pipeline_metadata = data.terraform_remote_state.internal_compute.outputs.data_pipeline_metadata_dynamo.name

  mongo_latest_version = {
    development = "0.0.72"
    qa          = "0.0.72"
    integration = "0.0.72"
    preprod     = "0.0.72"
    production  = "0.0.67"
  }

  payment_timelines_version = {
    development = "0.0.35"
    qa          = "0.0.35"
    integration = "0.0.35"
    preprod     = "0.0.35"
    production  = "0.0.35"
  }

  cbol_data_version = {
    development = "0.0.13"
    qa          = "0.0.13"
    integration = "0.0.13"
    preprod     = "0.0.13"
    production  = "0.0.13"
  }

  dynamodb_final_step = {
    development = "cbol-report"
    qa          = "cbol-report"
    integration = "cbol-report"
    preprod     = "cbol-report"
    production  = "cbol-report"
  }

  mongo_latest_max_retry_count = {
    development = "0"
    qa          = "0"
    integration = "0"
    preprod     = "0"
    production  = "2"
  }

  mongo_latest_alerts = {
    development = false
    qa          = false
    integration = false
    preprod     = true
    production  = true
  }

  hive_tez_container_size = {
    development = "5376"
    qa          = "5376"
    integration = "5376"
    preprod     = "7168"
    production  = "7168"
  }
  tez_grouping_min_size = {
    development = "1342177"
    qa          = "1342177"
    integration = "1342177"
    preprod     = "16777216"
    production  = "16777216"
  }

  tez_grouping_max_size = {
    development = "268435456"
    qa          = "268435456"
    integration = "268435456"
    preprod     = "1073741824"
    production  = "1073741824"
  }

  # 0.8 of hive_tez_container_size
  hive_tez_java_opts = {
    development = "-Xmx4300m"
    qa          = "-Xmx4300m"
    integration = "-Xmx4300m"
    preprod     = "-Xmx5734m"
    production  = "-Xmx5734m"
  }

  # 0.33 of hive_tez_container_size
  hive_auto_convert_join_noconditionaltask_size = {
    development = "1774"
    qa          = "1774"
    integration = "1774"
    preprod     = "2365"
    production  = "2365"
  }

  tez_am_resource_memory_mb = {
    development = "1024"
    qa          = "1024"
    integration = "1024"
    preprod     = "7168"
    production  = "7168"
  }

  # 0.8 of tez_am_resource_memory_mb
  tez_am_launch_cmd_opts = {
    development = "-Xmx816m"
    qa          = "-Xmx816m"
    integration = "-Xmx816m"
    preprod     = "-Xmx5734m"
    production  = "-Xmx5734m"
  }

  tez_task_resource_memory_mb = {
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "5734"
    production  = "5734"
  }

  hive_max_reducers = {
    development = "1099"
    qa          = "1099"
    integration = "1099"
    preprod     = "5000"
    production  = "5000"
  }

  hive_tez_sessions_per_queue = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "35"
    production  = "10"
  }

  use_capacity_reservation = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = false
  }

  emr_capacity_reservation_preference = local.use_capacity_reservation[local.environment] == true ? "open" : "none"

  emr_capacity_reservation_usage_strategy = local.use_capacity_reservation[local.environment] == true ? "use-capacity-reservations-first" : ""

  emr_subnet_non_capacity_reserved_environments = data.terraform_remote_state.common.outputs.aws_ec2_non_capacity_reservation_region

  mongo_latest_pushgateway_hostname = "${aws_service_discovery_service.mongo_latest_services.name}.${aws_service_discovery_private_dns_namespace.mongo_latest_services.name}"

  hive_scratch_dir_patch_files_s3_prefix = "non_source_control_large_files/emr_patches/hive_scratch_dir/"

  data_classification = {
    config_bucket  = data.terraform_remote_state.common.outputs.config_bucket
    config_prefix  = data.terraform_remote_state.aws_s3_object_tagger.outputs.pt_object_tagger_data_classification.config_prefix
    data_s3_prefix = data.terraform_remote_state.aws_s3_object_tagger.outputs.pt_object_tagger_data_classification.data_s3_prefix
  }
}
