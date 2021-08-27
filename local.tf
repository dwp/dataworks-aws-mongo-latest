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
    development = "0.0.67"
    qa          = "0.0.67"
    integration = "0.0.67"
    preprod     = "0.0.67"
    production  = "0.0.67"
  }

  payment_timelines_version = {
    development = "0.0.18"
    qa          = "0.0.18"
    integration = "0.0.18"
    preprod     = "0.0.18"
    production  = "0.0.18"
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
    preprod     = "32768"
    production  = "32768"
  }

  # 0.8 of hive_tez_container_size
  hive_tez_java_opts = {
    development = "-Xmx4300m"
    qa          = "-Xmx4300m"
    integration = "-Xmx4300m"
    preprod     = "-Xmx26214m"
    production  = "-Xmx26214m"
  }

  # 0.33 of hive_tez_container_size
  hive_auto_convert_join_noconditionaltask_size = {
    development = "1774"
    qa          = "1774"
    integration = "1774"
    preprod     = "10813"
    production  = "10813"
  }

  hive_bytes_per_reducer = {
    development = "10485760"
    qa          = "10485760"
    integration = "10485760"
    preprod     = "44739242"
    production  = "44739242"
  }

  # 0.1 of hive_tez_container_size
  tez_runtime_unordered_output_buffer_size_mb = {
    development = "537"
    qa          = "537"
    integration = "537"
    preprod     = "3276"
    production  = "3276"
  }

  # 0.4 of hive_tez_container_size
  tez_runtime_io_sort_mb = {
    development = "2150"
    qa          = "2150"
    integration = "2150"
    preprod     = "13107"
    production  = "13107"
  }

  tez_grouping_min_size = {
    development = "13421770"
    qa          = "13421770"
    integration = "13421770"
    preprod     = "52428800"
    production  = "52428800"
  }

  tez_grouping_max_size = {
    development = "67108850"
    qa          = "67108850"
    integration = "67108850"
    preprod     = "536870912"
    production  = "536870912"
  }

  tez_am_resource_memory_mb = {
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "13312"
    production  = "13312"
  }

  # 0.8 of tez_am_resource_memory_mb
  tez_am_launch_cmd_opts = {
    development = "-Xmx1638m"
    qa          = "-Xmx1638m"
    integration = "-Xmx1638m"
    preprod     = "-Xmx10649m"
    production  = "-Xmx10649m"
  }

  tez_task_resource_memory_mb = {
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "15360"
    production  = "15360"
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
    preprod     = "50"
    production  = "50"
  }

  hive_prewarm_container_count = {
    development = "20"
    qa          = "20"
    integration = "20"
    preprod     = "50"
    production  = "50"
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
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "8192"
    production  = "8192"
  }

  # 0.8 of map_reduce_memory_per_reducer
  map_reduce_java_opts_per_reducer = {
    development = "-Xmx1638m"
    qa          = "-Xmx1638m"
    integration = "-Xmx1638m"
    preprod     = "-Xmx6553m"
    production  = "-Xmx6553m"
  }

  map_reduce_memory_per_mapper = {
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "8192"
    production  = "8192"
  }

  # 0.8 of map_reduce_memory_per_mapper
  map_reduce_java_opts_per_mapper = {
    development = "-Xmx1638m"
    qa          = "-Xmx1638m"
    integration = "-Xmx1638m"
    preprod     = "-Xmx6553m"
    production  = "-Xmx6553m"
  }

  # Same as tez_am_resource_memory_mb
  map_reduce_memory_per_node = {
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "13312"
    production  = "13312"
  }

  # Bear in mind the core instance count
  llap_number_of_instances = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "15"
    production  = "15"
  }

  # Must be not more than the default queue can handle in the configuration for capacity scheduler
  llap_percent_allocation = {
    development = "0.6"
    qa          = "0.6"
    integration = "0.6"
    preprod     = "0.6"
    production  = "0.6"
  }

  llap_allocator_min = {
    development = "128Kb"
    qa          = "128Kb"
    integration = "128Kb"
    preprod     = "512Kb"
    production  = "512Kb"
  }

  llap_allocator_max = {
    development = "16Mb"
    qa          = "16Mb"
    integration = "16Mb"
    preprod     = "16Mb"
    production  = "16Mb"
  }

  # Set to yarn.scheduler.maximum-allocation-mb which is set by AWS according to instance type of core nodes
  llap_container_max_size_mb = {
    development = "57344"
    qa          = "57344"
    integration = "57344"
    preprod     = "253952"
    production  = "253952"
  }

  # llap_io_memory_size + (llap_number_of_executors_per_daemon x llap_executor_max_size_mb) must fit within llap_container_max_size_mb
  llap_executor_max_size_mb = {
    development = "4096"
    qa          = "4096"
    integration = "4096"
    preprod     = "8192"
    production  = "8192"
  }

  # llap_io_memory_size + (llap_number_of_executors_per_daemon x llap_executor_max_size_mb) must fit within llap_container_max_size_mb
  llap_number_of_executors_per_daemon = {
    development = "20"
    qa          = "20"
    integration = "20"
    preprod     = "20"
    production  = "20"
  }

  # llap_io_memory_size + (llap_number_of_executors_per_daemon x llap_executor_max_size_mb) must fit within llap_container_max_size_mb
  llap_io_memory_size = {
    development = "1G"
    qa          = "1G"
    integration = "1G"
    preprod     = "1G"
    production  = "1G"
  }

  yarn_total_preemption_per_round = format("%.2f", (1 / var.emr_core_instance_count[local.environment]))

  use_capacity_reservation = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  emr_capacity_reservation_preference = local.use_capacity_reservation[local.environment] == true ? "open" : "none"

  emr_capacity_reservation_usage_strategy = local.use_capacity_reservation[local.environment] == true ? "use-capacity-reservations-first" : ""

  emr_subnet_non_capacity_reserved_environments = "eu-west-2a"

  mongo_latest_pushgateway_hostname = "${aws_service_discovery_service.mongo_latest_services.name}.${aws_service_discovery_private_dns_namespace.mongo_latest_services.name}"

  hive_scratch_dir_patch_files_s3_prefix = "non_source_control_large_files/emr_patches/hive_scratch_dir/"

  data_classification = {
    config_bucket  = data.terraform_remote_state.common.outputs.config_bucket
    config_prefix  = data.terraform_remote_state.aws_s3_object_tagger.outputs.pt_object_tagger_data_classification.config_prefix
    data_s3_prefix = data.terraform_remote_state.aws_s3_object_tagger.outputs.pt_object_tagger_data_classification.data_s3_prefix
  }
}
