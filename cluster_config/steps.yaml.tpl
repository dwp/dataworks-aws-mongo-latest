---
BootstrapActions:
- Name: "run-log4j-patch"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/mongo_latest/patch-log4j-emr-6.3.1-v2.sh"
- Name: "download_scripts"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/mongo_latest/download_scripts.sh"
- Name: "start_ssm"
  ScriptBootstrapAction:
    Path: "file:/var/ci/start_ssm.sh"
- Name: "metadata"
  ScriptBootstrapAction:
    Path: "file:/var/ci/metadata.sh"
- Name: "config_hcs"
  ScriptBootstrapAction:
    Path: "file:/var/ci/config_hcs.sh"
    Args: [
      "${environment}",
      "${proxy_http_host}",
      "${proxy_http_port}",
      "${tanium_server_1}",
      "${tanium_server_2}",
      "${tanium_env}",
      "${tanium_port}",
      "${tanium_log_level}",
      "${install_tenable}",
      "${install_trend}",
      "${install_tanium}",
      "${tenantid}",
      "${token}",
      "${policyid}",
      "${tenant}"
    ]
- Name: "emr-setup"
  ScriptBootstrapAction:
    Path: "file:/var/ci/emr-setup.sh"
- Name: "metrics-setup"
  ScriptBootstrapAction:
    Path: "file:/var/ci/metrics-setup.sh"
- Name: "download-mongo-latest-sql"
  ScriptBootstrapAction:
    Path: "file:/var/ci/download_sql.sh"
    Args:
    - "aws-mongo-latest"
    - "${mongo_latest_version}"
    - "/opt/emr"
- Name: "download-payment-timelines-sql"
  ScriptBootstrapAction:
    Path: "file:/var/ci/download_sql.sh"
    Args:
    - "aws-payment-timelines"
    - "${payment_timelines_version}"
    - "/opt/emr/repos"
- Name: "download-cbol-sql"
  ScriptBootstrapAction:
    Path: "file:/var/ci/download_sql.sh"
    Args:
    - "aws-cbol-data"
    - "${cbol_data_version}"
    - "/opt/emr/repos"
- Name: "hive-setup"
  ScriptBootstrapAction:
    Path: "file:/var/ci/hive-setup.sh"
- Name: "replace-rpms-hive"
  ScriptBootstrapAction:
    Path: "file:/var/ci/replace-rpms-hive.sh"
    Args:
    - "hive"
Steps:
- Name: "courtesy-flush"
  HadoopJarStep:
    Args:
    - "file:/var/ci/courtesy-flush.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "create-mongo-latest-dbs"
  HadoopJarStep:
    Args:
    - "file:/var/ci/create-mongo-latest-dbs.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "mongo-latest-build"
  HadoopJarStep:
    Args:
    - "/opt/emr/aws-mongo-latest/scripts/executeUpdateAll.sh"
    - "${s3_published_bucket}"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "cbol-sql"
  HadoopJarStep:
    Args:
    - "/opt/emr/repos/aws-cbol-data/cbol-sql.sh"
    - "aws-cbol-data"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "cbol-report"
  HadoopJarStep:
    Args:
    - "/opt/emr/repos/aws-cbol-data/cbol-report.sh"
    - "dataegress/cbol-report"
    - "${s3_published_bucket}"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "pt-minus-1-sql"
  HadoopJarStep:
    Args:
    - "/opt/emr/repos/aws-payment-timelines/scripts/pt-minus-1-sql.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "mongo-latest-publish"
  HadoopJarStep:
    Args:
    - "/opt/emr/aws-mongo-latest/scripts/executePublishAll.sh"
    - "${s3_published_bucket}"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"
- Name: "flush-pushgateway"
  HadoopJarStep:
    Args:
    - "file:/var/ci/flush-pushgateway.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
