resource "aws_emr_security_configuration" "ebs_emrfs_em" {
  name          = "mongo_latest_ebs_emrfs"
  configuration = jsonencode(local.ebs_emrfs_em)
}

#TODO remove this
output "security_configuration" {
  value = aws_emr_security_configuration.ebs_emrfs_em
}

resource "aws_s3_object" "cluster" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/mongo_latest/cluster.yaml"
  content = templatefile("${path.module}/cluster_config/cluster.yaml.tpl",
    {
      s3_log_bucket          = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix          = local.s3_log_prefix
      ami_id                 = var.emr_ami_id
      service_role           = aws_iam_role.mongo_latest_emr_service.arn
      instance_profile       = aws_iam_instance_profile.mongo_latest.arn
      security_configuration = aws_emr_security_configuration.ebs_emrfs_em.id
      emr_release            = var.emr_release[local.environment]
    }
  )
}

resource "aws_s3_object" "instances" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/mongo_latest/instances.yaml"
  content = templatefile("${path.module}/cluster_config/instances.yaml.tpl",
    {
      keep_cluster_alive                  = local.keep_cluster_alive[local.environment]
      add_master_sg                       = aws_security_group.mongo_latest_common.id
      add_slave_sg                        = aws_security_group.mongo_latest_common.id
      subnet_ids                          = data.terraform_remote_state.internal_compute.outputs.mongo_latest_subnet.subnets.*.id
      master_sg                           = aws_security_group.mongo_latest_master.id
      slave_sg                            = aws_security_group.mongo_latest_slave.id
      service_access_sg                   = aws_security_group.mongo_latest_emr_service.id
      instance_type_core_one              = var.emr_instance_type_core_one[local.environment]
      instance_type_master                = var.emr_instance_type_master[local.environment]
      core_instance_count                 = var.emr_core_instance_count[local.environment]
      capacity_reservation_preference     = local.emr_capacity_reservation_preference
      capacity_reservation_usage_strategy = local.emr_capacity_reservation_usage_strategy
    }
  )
}

resource "aws_s3_object" "steps" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/mongo_latest/steps.yaml"
  content = templatefile("${path.module}/cluster_config/steps.yaml.tpl",
    {
      s3_config_bucket          = data.terraform_remote_state.common.outputs.config_bucket.id
      action_on_failure         = local.step_fail_action[local.environment]
      s3_published_bucket       = data.terraform_remote_state.common.outputs.published_bucket.id
      mongo_latest_version      = local.mongo_latest_version[local.environment]
      payment_timelines_version = local.payment_timelines_version[local.environment]
      cbol_data_version         = local.cbol_data_version[local.environment]
      environment               = local.hcs_environment[local.environment]
      proxy_http_host           = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_http_port           = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
    }
  )
}

resource "aws_s3_object" "configurations" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/mongo_latest/configurations.yaml"
  content = templatefile("${path.module}/cluster_config/configurations.yaml.tpl",
    {
      s3_log_bucket                                 = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix                                 = local.s3_log_prefix
      s3_published_bucket                           = data.terraform_remote_state.common.outputs.published_bucket.id
      hive_metastore_username                       = data.terraform_remote_state.internal_compute.outputs.metadata_store_users.mongo_latest_writer.username
      hive_metastore_pwd                            = data.terraform_remote_state.internal_compute.outputs.metadata_store_users.mongo_latest_writer.secret_name
      hive_metastore_endpoint                       = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.endpoint
      hive_metastore_database_name                  = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.database_name
      hive_tez_container_size                       = local.hive_tez_container_size[local.environment]
      hive_tez_java_opts                            = local.hive_tez_java_opts[local.environment]
      tez_am_resource_memory_mb                     = local.tez_am_resource_memory_mb[local.environment]
      tez_am_launch_cmd_opts                        = local.tez_am_launch_cmd_opts[local.environment]
      tez_grouping_min_size                         = local.tez_grouping_min_size[local.environment]
      tez_grouping_max_size                         = local.tez_grouping_max_size[local.environment]
      tez_task_resource_memory_mb                   = local.tez_task_resource_memory_mb[local.environment]
      hive_auto_convert_join_noconditionaltask_size = local.hive_auto_convert_join_noconditionaltask_size[local.environment]
      hive_max_reducers                             = local.hive_max_reducers[local.environment]
      hive_tez_sessions_per_queue                   = local.hive_tez_sessions_per_queue[local.environment]
      encryption_materials_provider_uri             = local.decryption_jar_s3_location
      encryption_materials_provider_class           = local.decryption_jar_class
      proxy_host                                    = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      full_no_proxy                                 = local.no_proxy
      tez_runtime_io_sort                           = format("%.0f", local.hive_tez_container_size[local.environment] * 0.4)
      tez_runtime_unordered_output_buffer_size_mb   = format("%.0f", local.hive_tez_container_size[local.environment] * 0.1)
    }
  )
}
