resource "aws_s3_bucket_object" "hadoop_lzo_jar" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/hadoop-lzo.jar"
  source  = "files/llap/encryption/hadoop-lzo.jar"
  etag    = filemd5("files/llap/encryption/hadoop-lzo.jar")
}

resource "aws_s3_bucket_object" "hadoop_lzo_0_4_19_jar" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/hadoop-lzo-0.4.19.jar"
  source  = "files/llap/encryption/hadoop-lzo-0.4.19.jar"
  etag    = filemd5("files/llap/encryption/hadoop-lzo-0.4.19.jar")
}

resource "aws_s3_bucket_object" "libgplcompression_a" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/native/libgplcompression.a"
  source  = "files/llap/encryption/native/libgplcompression.a"
  etag    = filemd5("files/llap/encryption/native/libgplcompression.a")
}

resource "aws_s3_bucket_object" "libgplcompression_so" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/native/libgplcompression.so"
  source  = "files/llap/encryption/native/libgplcompression.so"
  etag    = filemd5("files/llap/encryption/native/libgplcompression.so")
}=

resource "aws_s3_bucket_object" "libgplcompression_so_0" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/native/libgplcompression.so.0"
  source  = "files/llap/encryption/native/libgplcompression.so.0"
  etag    = filemd5("files/llap/encryption/native/libgplcompression.so.0")
}=

resource "aws_s3_bucket_object" "libgplcompression_so_0_0_0" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/native/libgplcompression.so.0.0.0"
  source  = "files/llap/encryption/native/libgplcompression.so.0.0.0"
  etag    = filemd5("files/llap/encryption/native/libgplcompression.so.0.0.0")
}
