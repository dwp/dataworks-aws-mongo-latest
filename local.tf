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

  mongo_latest_emr_lambda_schedule = {
    development = "1 0 * * ? 2099"
    qa          = "1 0 * * ? *"
    integration = "00 14 6 Jul ? 2020" # trigger one off temp increase for DW-4437 testing
    preprod     = "1 0 * * ? *"
    production  = "1 0 * * ? 2025"
  }

  mongo_latest_log_level = {
    development = "DEBUG"
    qa          = "DEBUG"
    integration = "DEBUG"
    preprod     = "INFO"
    production  = "INFO"
  }

  amazon_region_domain = "${data.aws_region.current.name}.amazonaws.com"
  endpoint_services    = ["dynamodb", "ec2", "ec2messages", "glue", "kms", "logs", "monitoring", ".s3", "s3", "secretsmanager", "ssm", "ssmmessages"]
  no_proxy             = "169.254.169.254,${join(",", formatlist("%s.%s", local.endpoint_services, local.amazon_region_domain))},${data.terraform_remote_state.metrics_infrastructure.outputs.mongo_latest_pushgateway_hostname}"

  ebs_emrfs_em = {
    EncryptionConfiguration = {
      EnableInTransitEncryption = false
      EnableAtRestEncryption    = true
      AtRestEncryptionConfiguration = {

        S3EncryptionConfiguration = {
          EncryptionMode             = "CSE-Custom"
          S3Object                   = "s3://${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id}/emr-encryption-materials-provider/encryption-materials-provider-all.jar"
          EncryptionKeyProviderClass = "uk.gov.dwp.dataworks.dks.encryptionmaterialsprovider.DKSEncryptionMaterialsProvider"
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
    development = "0.0.63"
    qa          = "0.0.63"
    integration = "0.0.63"
    preprod     = "0.0.63"
    production  = "0.0.63"
  }

  dynamodb_final_step = {
    development = "executeUpdateAll"
    qa          = "executeUpdateAll"
    integration = "executeUpdateAll"
    preprod     = "executeUpdateAll"
    production  = "executeUpdateAll"
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
    development = "2688"
    qa          = "2688"
    integration = "2688"
    preprod     = "10240"
    production  = "10240"
  }

  # 0.8 of hive_tez_container_size
  hive_tez_java_opts = {
    development = "-Xmx2150m"
    qa          = "-Xmx2150m"
    integration = "-Xmx2150m"
    preprod     = "-Xmx8192m"
    production  = "-Xmx8192m"
  }

  # 0.33 of hive_tez_container_size
  hive_auto_convert_join_noconditionaltask_size = {
    development = "896"
    qa          = "896"
    integration = "896"
    preprod     = "3379"
    production  = "3379"
  }

  hive_bytes_per_reducer = {
    development = "5242880"
    qa          = "5242880"
    integration = "5242880"
    preprod     = "33554432"
    production  = "33554432"
  }

  # 0.1 of hive_tez_container_size
  tez_runtime_unordered_output_buffer_size_mb = {
    development = "268"
    qa          = "268"
    integration = "268"
    preprod     = "1024"
    production  = "1024"
  }

  # 0.4 of hive_tez_container_size
  tez_runtime_io_sort_mb = {
    development = "1075"
    qa          = "1075"
    integration = "1075"
    preprod     = "4096"
    production  = "4096"
  }

  tez_grouping_min_size = {
    development = "13421770"
    qa          = "13421770"
    integration = "13421770"
    preprod     = "104857600"
    production  = "104857600"
  }

  tez_grouping_max_size = {
    development = "67108850"
    qa          = "67108850"
    integration = "67108850"
    preprod     = "536870912"
    production  = "536870912"
  }

  tez_am_resource_memory_mb = {
    development = "1024"
    qa          = "1024"
    integration = "1024"
    preprod     = "8192"
    production  = "8192"
  }

  # 0.8 of tez_am_resource_memory_mb
  tez_am_launch_cmd_opts = {
    development = "-Xmx819m"
    qa          = "-Xmx819m"
    integration = "-Xmx819m"
    preprod     = "-Xmx6553m"
    production  = "-Xmx6553m"
  }

  # 0.8 of hive_tez_container_size
  tez_task_resource_memory_mb = {
    development = "1024"
    qa          = "1024"
    integration = "1024"
    preprod     = "8192"
    production  = "8192"
  }

  hive_max_reducers = {
    development = "1099"
    qa          = "1099"
    integration = "1099"
    preprod     = "5000"
    production  = "5000"
  }

  hive_tez_sessions_per_queue = {
    development = "20"
    qa          = "20"
    integration = "20"
    preprod     = "75"
    production  = "75"
  }

  hive_prewarm_container_count = {
    development = "20"
    qa          = "20"
    integration = "20"
    preprod     = "75"
    production  = "75"
  }

  map_reduce_vcores_per_node = {
    development = "4"
    qa          = "4"
    integration = "4"
    preprod     = "12"
    production  = "12"
  }

  map_reduce_vcores_per_task = {
    development = "2"
    qa          = "2"
    integration = "2"
    preprod     = "5"
    production  = "5"
  }

  map_reduce_memory_per_reducer = {
    development = "4096"
    qa          = "4096"
    integration = "4096"
    preprod     = "8192"
    production  = "8192"
  }

  # 0.8 of map_reduce_memory_per_reducer
  map_reduce_java_opts_per_reducer = {
    development = "-Xmx3276m"
    qa          = "-Xmx3276m"
    integration = "-Xmx3276m"
    preprod     = "-Xmx6553m"
    production  = "-Xmx6553m"
  }

  map_reduce_memory_per_mapper = {
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "5120"
    production  = "5120"
  }

  # 0.8 of map_reduce_memory_per_mapper
  map_reduce_java_opts_per_mapper = {
    development = "-Xmx1638m"
    qa          = "-Xmx1638m"
    integration = "-Xmx1638m"
    preprod     = "-Xmx4096m"
    production  = "-Xmx4096m"
  }

  # Same as tez_am_resource_memory_mb
  map_reduce_memory_per_node = {
    development = "4096"
    qa          = "4096"
    integration = "4096"
    preprod     = "8192"
    production  = "8192"
  }

  emr_capacity_reservation_preference = {
    development = "none"
    qa          = "open"
    integration = "none"
    preprod     = "open"
    production  = "open"
  }

  emr_capacity_reservation_usage_strategy = {
    development = ""
    qa          = "use-capacity-reservations-first"
    integration = ""
    preprod     = "use-capacity-reservations-first"
    production  = "use-capacity-reservations-first"
  }

  emr_subnet_non_capacity_reserved_environments = "eu-west-2b"
}
