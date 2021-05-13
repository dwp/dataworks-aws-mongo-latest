#!/bin/bash

set -Eeuo pipefail

cwa_metrics_collection_interval="$1"
cwa_namespace="$2"
cwa_log_group_name="$3"
cwa_bootstrap_loggrp_name="$5"
cwa_steps_loggrp_name="$6"
cwa_yarnspark_loggrp_name="$7"
cwa_tests_loggrp_name="$8"

export AWS_DEFAULT_REGION="${4}"

# Create config file required for CloudWatch Agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWAGENTCONFIG
{
  "agent": {
    "metrics_collection_interval": ${cwa_metrics_collection_interval},
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-amazon-cloudwatch-agent.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-secure",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-cloud-init-output.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/acm-cert-retriever.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-acm-cert-retriever.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/hive_setup.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-hive_setup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/metrics-setup.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-metrics-setup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/emr-setup.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-emr-setup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/update_dynamo_sh.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-update_dynamo_sh.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/download_scripts.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-download-scripts.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/status_metrics_sh.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-status_metrics_sh.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/hive-tables-creation.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-hive-tables-creation.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/create-hive-tables.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-create-hive-tables.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hadoop-yarn/containers/application_*/container_*/stdout**",
            "log_group_name": "${cwa_yarnspark_loggrp_name}",
            "log_stream_name": "{instance_id}-spark-stdout.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hadoop-yarn/containers/application_*/container_*/stderr**",
            "log_group_name": "${cwa_yarnspark_loggrp_name}",
            "log_stream_name": "{instance_id}-spark-stderror.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hadoop-yarn/yarn-yarn-nodemanager**.log",
            "log_group_name": "${cwa_yarnspark_loggrp_name}",
            "log_stream_name": "{instance_id}-yarn_nodemanager.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/flush-pushgateway.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-flush-pushgateway.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/create-mongo_latest-dbs.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-create-mongo_latest-dbs.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/executeUpdateContractClaimant.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-executeUpdateContractClaimant.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/executeUpdateStatement.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-executeUpdateStatement.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/executeUpdateToDo.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-executeUpdateToDo.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/executeUpdateAppointment.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-executeUpdateAppointment.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mongo_latest/e2e.log",
            "log_group_name": "${cwa_tests_loggrp_name}",
            "log_stream_name": "{instance_id}-e2e.log",
            "timezone": "UTC"
          }

        ]
      }
    },
    "log_stream_name": "${cwa_namespace}",
    "force_flush_interval" : 15
  }
}
CWAGENTCONFIG

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
systemctl start amazon-cloudwatch-agent
