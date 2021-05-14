# dataworks-aws-mongo-latest

The Mongo Latest cluster runs the aws-mongo-latest SQL data product and builds the infrastructure needed for it to run on AWS.

# Overview

![Overview](docs/overview.png)

## Dynamo-db table

There is a dynamo-db table that exists which tracks the status of all Mongo Latest runs. This table is named `data_pipeline_metadata`. In order to populate this table, the `emr-setup` bootstrap step kicks off a shell script named `update_dynamo.sh` which runs in the background.

This script waits for certain files to exist on the local file systems. These files contain information passed to the cluster from SNS (like the correlation id) and the first step of the cluster than saves them to the files.

When the files are found, then the script updates dynamo db with a row for the current run of the cluster (when the row already exists, it's a retry scenario, see below). Then the script loops in the background for the lifecycle of the cluster. When a step is completed, the current step field is updated in dynamo db and when the cluster is finished the status is updated with the final cluster status. Cancelled clusters are set to failed.

### Retries

If a cluster fails, then the status is updated in the dynamo db table to failed. When a new cluster starts, before it inserts the new dynamo db row, it checks if one exists. If it does, then it checks the last run step and the status and if the status is failed, it saves off this status to a local file.

Whenever a step starts on a cluster, it calls a common method which checks if this local file exists. If it does not (i.e. this is not a retry scenario) then the step continues a normal. However if the file does exist, then the step checks if the failed cluster was running the same step when it failed. If it was, then it runs the step as normal and the local files is deleted so as not to affect subsequent steps. However if the step name does not match, this step is assumed to have completed before and therefore is skipped this time.

In this way, we are able to retry the entire cluster but not repeat steps that have already succeeded, therefore saving us potentially hours or time for retry scenarios.

## Concourse pipeline

There is a concourse pipeline for mongo latest named `aws-mongo-latest`. The code for this pipeline is in the `ci` folder. The main part of the pipeline (the `master` group) deploys the infrastructure and runs the e2e tests. There are a number of groups for rotating passwords and there are also admin groups for each environment.

### Admin jobs

There are a number of available admin jobs for each environment.

#### Start cluster

This job will start an Mongo Latest cluster running. In order to make the cluster do what you want it to do, you can alter the following environment variables in the pipeline config and then run `aviator` to update the pipeline before kicking it off:

1. EXPORT_DATE (required) -> the date the data was exported, i.e `2021-04-01`
1. CORRELATION_ID (required) -> the correlation id for this run, i.e. `generate_snapshots_preprod_generate_full_snapshots_4_full`

#### Stop clusters

For stopping clusters, you can run the `stop-cluster` job to terminate ALL current `mongo-latest` clusters on the environment.

### Clear dynamo row (i.e. for a cluster restart)

Sometimes the Mongo Latest cluster is required to restart from the beginning instead of restarting from the failure point.
To be able to do a full cluster restart, delete the associated DynamoDB row if it exists. The keys to the row are `Correlation_Id` and `DataProduct` in the DynamoDB table storing cluster state information (see [Retries](#retries)).   
The `clear-dynamodb-row` job is responsible for carrying out the row deletion.

To do a full cluster restart

* Manually enter CORRELATION_ID and DATA_PRODUCT of the row to delete to the `clear-dynamodb-row` job and run aviator.


    ```
    jobs:
      - name: dev-clear-dynamodb-row
        plan:
          - .: (( inject meta.plan.clear-dynamodb-row ))
            config:
              params:
                AWS_ROLE_ARN: arn:aws:iam::((aws_account.development)):role/ci
                AWS_ACC: ((aws_account.development))
                CORRELATION_ID: <Correlation_Id of the row to delete>
                DATA_PRODUCT: <DataProduct of the row to delete>

    ```
* Run the admin job to `<env>-clear-dynamodb-row`

* You can then run `start-cluster` job with the same `Correlation_Id` from fresh.

# Status Metrics

In order to generate status metrics, the emr-setup bootstrap step kicks off a shell script named status_metrics.sh which runs in the background.

This script loops in the background for the lifecycle of the cluster and sends a metric called `mongo_latest_status` to the Mongo Latest pushgateway. This metric has the following
values which map to a certain cluster status

| Cluster Status  | Metric Value |
| ------------- | ------------- |
| Running    | 1
| Completed  | 2  |
| Failed  | 3  |
| Cancelled  | 4  |

## Configuration

Tez and Hive settings are calculated according to the instance types and sizes using the following guides:

* https://community.cloudera.com/t5/Community-Articles/Demystify-Apache-Tez-Memory-Tuning-Step-by-Step/ta-p/245279
* https://community.cloudera.com/t5/Community-Articles/Hive-Understanding-concurrent-sessions-queue-allocation/ta-p/247407
* https://community.cloudera.com/t5/Community-Articles/Hive-on-Tez-Performance-Tuning-Determining-Reducer-Counts/ta-p/245680
* https://cwiki.apache.org/confluence/display/TEZ/How+initial+task+parallelism+works
* https://stackoverflow.com/questions/41454796/aws-emr-parallel-mappers/43404403#43404403
