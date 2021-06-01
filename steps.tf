resource "aws_s3_bucket_object" "flush_pushgateway" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/mongo_latest/flush-pushgateway.sh"
  content = templatefile("${path.module}/steps/flush-pushgateway.sh",
    {
      mongo_latest_pushgateway_hostname = local.mongo_latest_pushgateway_hostname
    }
  )
}

resource "aws_s3_bucket_object" "courtesy_flush" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/mongo_latest/courtesy-flush.sh"
  content = templatefile("${path.module}/steps/courtesy-flush.sh",
    {
      mongo_latest_pushgateway_hostname = local.mongo_latest_pushgateway_hostname
    }
  )
}

resource "aws_s3_bucket_object" "create-mongo-latest-dbs" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/mongo_latest/create-mongo-latest-dbs.sh"
  content = templatefile("${path.module}/steps/create-mongo-latest-dbs.sh",
    {
      publish_bucket      = format("s3://%s", data.terraform_remote_state.common.outputs.published_bucket.id)
      processed_bucket    = format("s3://%s", data.terraform_remote_state.common.outputs.processed_bucket.id)
      dynamodb_table_name = local.data_pipeline_metadata
    }
  )
}
