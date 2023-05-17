---
Configurations:
- Classification: "core-site"
  Properties:
    "hadoop.proxyuser.livy.groups": "*"
    "hadoop.proxyuser.livy.hosts": "*"

- Classification: "livy-conf"
  Properties:
    "livy.file.local-dir-whitelist": /
    "livy.impersonation.enabled": "true"
    "livy.repl.enable-hive-context": "true"
    "livy.server.port": "8998"
    "livy.spark.deploy-mode": "cluster"
    "livy.spark.yarn.security.credentials.hiveserver2.enabled": "true"

- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation-enable": "true"
    "yarn.log-aggregation.retain-seconds": "-1"
    "yarn.nodemanager.remote-app-log-dir": "s3://${s3_log_bucket}/${s3_log_prefix}/yarn"
    "yarn.resourcemanager.scheduler.class": "org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler"
    "yarn.scheduler.fair.preemption": "true"

- Classification: "spark"
  Properties:
    "maximizeResourceAllocation": "false"

- Classification: "spark-defaults"
  Properties:
    "spark.driver.extraJavaOptions": "-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70
      -XX:MaxHeapFreeRatio=70 -XX:+CMSClassUnloadingEnabled -XX:OnOutOfMemoryError='kill
      -9 %p' -Dhttp.proxyHost='${proxy_host}' -Dhttp.proxyPort='3128' -Dhttp.nonProxyHosts='${full_no_proxy}'
      -Dhttps.proxyHost='${proxy_host}' -Dhttps.proxyPort='3128'"
    "spark.executor.extraJavaOptions": "-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps
      -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 -XX:MaxHeapFreeRatio=70
      -XX:+CMSClassUnloadingEnabled -XX:OnOutOfMemoryError='kill -9 %p' -Dhttp.proxyHost='${proxy_host}'
      -Dhttp.proxyPort='3128' -Dhttp.nonProxyHosts='${full_no_proxy}' -Dhttps.proxyHost='${proxy_host}'
      -Dhttps.proxyPort='3128'"
    "spark.r.command": "/opt/R/R-3.6.3/bin/Rscript"
    "spark.r.shell.command": "/opt/R/R-3.6.3/bin/R"
    "spark.sql.catalogImplementation": "hive"

- Classification: "spark-hive-site"
  Properties:
    "hive.exec.dynamic.partition.mode": "nonstrict"
    "hive.server2.authentication": "nosasl"
    "hive.support.concurrency": "true"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionPassword": ${hive_metastore_pwd}
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}"
    "javax.jdo.option.ConnectionUserName": "${hive_metastore_username}"

- Classification: "hive-site"
  Properties:
  # performance testing start
    "hive.exec.orc.compression.strategy": "SPEED"
    "hive.exec.orc.default.compress": "ZLIB"
    "hive.exec.orc.encoding.strategy": "SPEED"
    "hive.auto.convert.join": "TRUE"
    "hive.exec.orc.default.block.size": "568435456"
    "hive.exec.orc.default.stripe.size": "568435456"
    "hive.exec.input.listing.max.threads": "40"
   # performance testing end
    "hive.exec.dynamic.partition.mode": "nonstrict"
    "hive.server2.authentication": "nosasl"
    "hive.support.concurrency": "true"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionPassword": ${hive_metastore_pwd}
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}?createDatabaseIfNotExist=true"
    "javax.jdo.option.ConnectionUserName": "${hive_metastore_username}"
    "hive.metastore.warehouse.dir": "s3://${s3_published_bucket}/mongo_latest/hive/external"
    "hive.metastore.client.socket.timeout": "10800"
    "hive.strict.checks.cartesian.product": "false"
    "hive.mapred.mode": "nonstrict"
    "hive.tez.container.size": "${hive_tez_container_size}"
    "hive.tez.java.opts": "${hive_tez_java_opts}"
    "hive.auto.convert.join.noconditionaltask.size": "${hive_auto_convert_join_noconditionaltask_size}"
    "hive.exec.failure.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.post.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.pre.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive_timeline_logging_enabled": "true"
    "hive.convert.join.bucket.mapjoin.tez": "false"
    "hive.metastore.schema.verification": "false"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "1"
    "hive.exec.parallel": "true"
# do not turn vectorisation on see DW-6676
    "hive.vectorized.execution.enabled": "false"
    "hive.vectorized.execution.reduce.enabled": "true"
    "hive.vectorized.complex.types.enabled": "true"
    "hive.vectorized.use.row.serde.deserialize": "true"
    "hive.vectorized.execution.ptf.enabled": "true"
    "hive.vectorized.row.serde.inputformat.excludes": ""
    "hive.server2.tez.sessions.per.default.queue": "${hive_tez_sessions_per_queue}"
    "hive.server2.tez.initialize.default.sessions": "true"
    "hive.default.fileformat": "TextFile"
    "hive.default.fileformat.managed": "ORC"
    "hive.exec.orc.split.strategy": "HYBRID"
    "hive.merge.orcfile.stripe.level": "true"
    "hive.orc.compute.splits.num.threads": "10"
    "hive.orc.splits.include.file.footer": "true"
    "hive.compactor.abortedtxn.threshold": "1000"
    "hive.compactor.check.interval": "300"
    "hive.compactor.delta.num.threshold": "10"
    "hive.compactor.delta.pct.threshold": "0.1f"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "1"
    "hive.compactor.worker.timeout": "86400"
    "hive.blobstore.optimizations.enabled": "true"
    "hive.blobstore.use.blobstore.as.scratchdir": "false"
    "hive.server2.tez.session.lifetime": "0"
    "hive.exec.reducers.max": "${hive_max_reducers}"
    "hive.mapjoin.bucket.cache.size": "10000"
    "hive.merge.nway.joins": "true"
    "hive.optimize.sort.dynamic.partition": "false"
    "hive.llap.execution.mode": "none"
    "hive.vectorized.groupby.maxentries": "100000"
    "hive.vectorized.use.vectorized.input.format": "true"
    "hive.vectorized.groupby.checkinterval": "4096"
    "hive.vectorized.groupby.flush.percent": "0.1"
    "hive.vectorized.use.checked.expressions": "false"
    "hive.vectorized.adaptor.usage.mode": "chosen"
    "hive.vectorized.use.vector.serde.deserialize": "true"
    "hive.exec.max.dynamic.partitions.pernode": "1000"
    "hive.aux.jars.path": "/usr/lib/hadoop-lzo/lib/,/usr/lib/hadoop-lzo/lib/native/,/usr/lib/hadoop-yarn/,/usr/lib/hadoop-yarn/timelineservice/,/usr/lib/hadoop-yarn/timelineservice/lib/,/usr/lib/hadoop-yarn/lib/,/usr/lib/hadoop/lib,/usr/lib/hive/lib/,/usr/share/aws/aws-java-sdk/,/usr/share/aws/emr/ddb/lib/,/usr/share/aws/emr/emrfs/auxlib/,/opt/custom_jars/,/usr/lib/hive/auxlib/"

- Classification: "emrfs-site"
  Properties:
  # performance testing start
    "fs.s3a.threads.core": "3000"
    "fs.s3a.connection.maximum": "4500"
    "fs.s3a.threads.max": "3000"
    "fs.s3a.max.total.tasks": "2000"
  # performance testing start
    "fs.s3.maxRetries": "20"
    "fs.s3.cse.enabled": "true"
    "fs.s3.cse.encryptionMaterialsProvider.uri": "${encryption_materials_provider_uri}"
    "fs.s3.cse.encryptionMaterialsProvider": "${encryption_materials_provider_class}"
  
- Classification: "tez-site"
  Properties:
    "tez.task.resource.memory.mb": "${tez_task_resource_memory_mb}"
    "tez.am.resource.memory.mb": "${tez_am_resource_memory_mb}"
    "tez.am.launch.cmd-opts": "${tez_am_launch_cmd_opts}"

- Classification: "hive-env"
  Configurations:
  - Classification: "export"
    Properties:
      "HADOOP_HEAPSIZE": "2000"

- Classification: "hadoop-env"
  Configurations:
  - Classification: "export"
    Properties:
      "HADOOP_NAMENODE_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7101:/opt/emr/metrics/prometheus_config.yml\""
      "HADOOP_DATANODE_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7103:/opt/emr/metrics/prometheus_config.yml\""

- Classification: "yarn-env"
  Configurations:
  - Classification: "export"
    Properties:
      "YARN_RESOURCEMANAGER_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7105:/opt/emr/metrics/prometheus_config.yml\""
      "YARN_NODEMANAGER_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7107:/opt/emr/metrics/prometheus_config.yml\""
