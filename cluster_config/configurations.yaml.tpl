---
Configurations:
- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation-enable": "true"
    "yarn.nodemanager.remote-app-log-dir": "s3://${s3_log_bucket}/${s3_log_prefix}/yarn"
    "yarn.nodemanager.vmem-check-enabled": "false"
    "yarn.nodemanager.pmem-check-enabled": "false"
    "yarn.acl.enable": "true"
    "yarn.resourcemanager.scheduler.monitor.enable": "true"
    "yarn.resourcemanager.monitor.capacity.preemption.total_preemption_per_round": "${yarn_total_preemption_per_round}"
    "yarn.resourcemanager.scheduler.class": "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"

- Classification: "capacity-scheduler"
  Properties:
    "yarn.scheduler.capacity.maximum-applications": "10000"
    "yarn.scheduler.capacity.node-locality-delay": "40"
    "yarn.scheduler.capacity.maximum-am-resource-percent": "0.95"
    "yarn.scheduler.capacity.resource-calculator": "org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator"
    "yarn.scheduler.capacity.root.queues": "default,appqueue1"
    "yarn.scheduler.capacity.root.ordering-policy": "priority-utilization"
    "yarn.scheduler.capacity.root.default.capacity": "90"
    "yarn.scheduler.capacity.root.default.maximum-capacity": "100"
    "yarn.scheduler.capacity.root.default.acl_submit_applications": "*"
    "yarn.scheduler.capacity.root.default.default-application-priority": "2"
    "yarn.scheduler.capacity.root.appqueue1.capacity": "10"
    "yarn.scheduler.capacity.root.appqueue1.acl_submit_applications": "*"
    "yarn.scheduler.capacity.root.appqueue1.maximum-capacity": "30"
    "yarn.scheduler.capacity.root.appqueue1.state": "RUNNING"
    "yarn.scheduler.capacity.root.appqueue1.default-application-priority": "1"
    "yarn.scheduler.capacity.root.appqueue1.ordering-policy": "fifo"

- Classification: "hive"
  Properties:
    "hive.llap.enabled": "true"
    "hive.llap.percent-allocation": "${llap_percent_allocation}"
    "hive.llap.num-instances": "${llap_number_of_instances}"

- Classification: "hive-site"
  Properties:
    "hive.metastore.warehouse.dir": "s3://${s3_published_bucket}/mongo_latest/hive/external"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "hive.enforce.bucketing": "true"
    "hive.exec.dynamic.partition": "true"
    "hive.exec.dynamic.partition.mode": "nonstrict"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "1"
    "hive.compactor.worker.timeout": "86400"
    "hive.driver.parallel.compilation": "true"
    "hive.exec.compress.intermediate": "true"
    "hive.exec.compress.output": "true"
    "hive.server2.idle.session.timeout": "1d"
    "hive.server2.idle.operation.timeout": "6h"
    "hive.tez.cpu.vcores": "-1"
    "hive.support.concurrency": "true"
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}?createDatabaseIfNotExist=true"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionUserName": "${hive_metastore_username}"
    "javax.jdo.option.ConnectionPassword": "${hive_metastore_pwd}"
    "hive.metastore.client.socket.timeout": "7200"
    "hive.mapred.mode": "nonstrict"
    "hive.strict.checks.cartesian.product": "false"
    "hive.exec.parallel": "true"
    "hive.exec.parallel.thread.number": "128"
    "hive.exec.failure.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.post.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.pre.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.cbo.enable": "true"
    "hive.compute.query.using.stat": "true"
    "hive.stats.fetch.column.stats": "true"
    "hive.stats.fetch.partition.stats": "true"
    "hive.vectorized.execution.enabled": "true"
    "hive.vectorized.execution.reduce.enabled": "true"
    "hive.vectorized.execution.reduce.groupby.enabled": "true"
    "hive.vectorized.complex.types.enabled": "true"
    "hive.vectorized.use.row.serde.deserialize": "true"
    "hive.vectorized.execution.ptf.enabled": "true"
    "hive.vectorized.row.serde.inputformat.excludes": ""
    "hive_timeline_logging_enabled": "true"
    "hive.server2.tez.default.queues": "appqueue1"
    "hive.server2.tez.sessions.per.default.queue": "${hive_tez_sessions_per_queue}"
    "hive.server2.tez.initialize.default.sessions": "true"
    "hive.exec.reducers.bytes.per.reducer": "${hive_bytes_per_reducer}"
    "hive.blobstore.optimizations.enabled": "true"
    "hive.blobstore.use.blobstore.as.scratchdir": "false"
    "hive.exec.input.listing.max.threads": "3"
    "hive.prewarm.enabled": "true"
    "hive.prewarm.numcontainers": "${hive_prewarm_container_count}"
    "hive.tez.container.size": "${hive_tez_container_size}"
    "hive.tez.java.opts": "${hive_tez_java_opts}"
    "hive.auto.convert.join": "true"
    "hive.auto.convert.join.noconditionaltask": "true"
    "hive.auto.convert.join.noconditionaltask.size": "${hive_auto_convert_join_noconditionaltask_size}"
    "hive.server2.tez.session.lifetime": "0"
    "hive.server2.async.exec.threads": "1500"
    "hive.server2.async.exec.wait.queue.size": "1500"
    "hive.server2.async.exec.keepalive.time": "120"
    "hive.tez.min.partition.factor": "0.25"
    "hive.tez.max.partition.factor": "2.0"
    "hive.exec.reducers.max": "${hive_max_reducers}"
    "hive.default.fileformat": "ORC"
    "hive.exec.orc.default.compress": "ZLIB"
    "hive.exec.orc.default.block.size": "268435456"
    "hive.exec.orc.encoding.strategy": "SPEED"
    "hive.exec.orc.split.strategy": "HYBRID"
    "hive.exec.orc.default.row.index.stride": "10000"
    "hive.exec.orc.default.stripe.size": "268435456"
    "hive.exec.orc.compression.strategy": "SPEED"
    "hive.optimize.sort.dynamic.partition": "true"
    "hive.stats.autogather": "true"
    "hive.tez.auto.reducer.parallelism": "true"
    "hive.tez.bucket.pruning": "true"
    "hive.optimize.reducededuplication.min.reducer": "1"
    "hive.server2.enable.doAs": "false"
    "hive.aux.jars.path": "/usr/lib/hadoop-lzo/lib/,/usr/lib/hadoop-lzo/lib/native/,/usr/lib/hadoop-yarn/,/usr/lib/hadoop-yarn/timelineservice/,/usr/lib/hadoop-yarn/timelineservice/lib/,/usr/lib/hadoop-yarn/lib/,/usr/lib/hadoop/lib,/usr/lib/hive/lib/,/usr/share/aws/aws-java-sdk/,/usr/share/aws/emr/ddb/lib/,/usr/share/aws/emr/emrfs/auxlib/,/opt/custom_jars/,/usr/lib/hive/auxlib/"
    "hive.llap.io.allocator.alloc.min": "${llap_allocator_min}"
    "hive.llap.io.allocator.alloc.max": "${llap_allocator_max}"
    "hive.llap.daemon.yarn.container.mb": "${llap_container_max_size_mb}"
    "hive.llap.daemon.memory.per.instance.mb": "${llap_executor_max_size_mb}"
    "hive.llap.daemon.num.executors": "${llap_number_of_executors_per_daemon}"
    "hive.llap.io.memory.size": "${llap_io_memory_size}"
    "hive.llap.execution.mode": "all"

- Classification: "tez-site"
  Properties:
    "tez.task.resource.memory.mb": "${tez_task_resource_memory_mb}"
    "tez.grouping.min-size": "${tez_grouping_min_size}"
    "tez.grouping.max-size": "${tez_grouping_max_size}"
    "tez.am.resource.memory.mb": "${tez_am_resource_memory_mb}"
    "tez.am.launch.cmd-opts": "${tez_am_launch_cmd_opts}"
    "tez.am.container.reuse.enabled": "true"
    "tez.am.container.reuse.non-local-fallback.enabled": "true"
    "tez.runtime.io.sort.mb": "${tez_runtime_io_sort_mb}"
    "tez.runtime.unordered.output.buffer.size-mb": "${tez_runtime_unordered_output_buffer_size_mb}"
    "tez.runtime.report.partition.stats": "true"
    "tez.runtime.pipelined.sorter.lazy-allocate.memory": "true"
    "tez.runtime.pipelined.sorter.sort.threads": "2"
    "tez.counters.max": "16000"
    "tez.counters.max.groups": "500"
    "tez.runtime.optimize.local.fetch": "true"
    "tez.session.client.timeout.secs": "-1"

- Classification: "mapred-site"
  Properties:
    "mapreduce.map.memory.mb": "${map_reduce_memory_per_mapper}"
    "mapreduce.reduce.memory.mb": "${map_reduce_memory_per_reducer}"
    "mapreduce.map.java.opts": "${map_reduce_java_opts_per_mapper}"
    "mapreduce.reduce.java.opts": "${map_reduce_java_opts_per_reducer}"
    "mapreduce.map.resource.vcores": "${map_reduce_vcores_per_task}"
    "mapreduce.reduce.resource.vcores": "${map_reduce_vcores_per_task}"
    "yarn.app.mapreduce.am.resource.vcores": "${map_reduce_vcores_per_node}"
    "yarn.app.mapreduce.am.resource.mb": "${map_reduce_memory_per_node}"
    "mapred.reduce.tasks": "-1"
    "mapreduce.cluster.acls.enabled": "true"
    "mapreduce.job.counters.max": "200"
    "mapreduce.job.reduce.slowstart.completedmaps": "0.7"
    "mapreduce.map.output.compress": "true"
    "mapreduce.output.fileoutputformat.compress": "true"
    "mapreduce.output.fileoutputformat.compress.type": "BLOCK"
    "mapreduce.reduce.shuffle.parallelcopies": "30"
    "mapreduce.task.io.sort.factor": "100"
    "mapreduce.task.io.sort.mb": "1024"

- Classification: "emrfs-site"
  Properties:
    "fs.s3.maxConnections": "10000"
    "fs.s3.maxRetries": "20"
    "fs.s3.cse.enabled": "true"
    "fs.s3.cse.encryptionMaterialsProvider.uri": "${encryption_materials_provider_uri}"
    "fs.s3.cse.encryptionMaterialsProvider": "${encryption_materials_provider_class}"

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
