data "local_file" "hadoop_lzo_jar" {
  filename = "files/llap/encryption/hadoop-lzo.jar"
}

resource "aws_s3_bucket_object" "hadoop_lzo_jar" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/hadoop-lzo.jar"
  content = data.local_file.hadoop_lzo_jar.content
}

data "local_file" "hadoop_lzo_0_4_19_jar" {
  filename = "files/llap/encryption/hadoop-lzo-0.4.19.jar"
}

resource "aws_s3_bucket_object" "hadoop_lzo_0_4_19_jar" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/hadoop-lzo-0.4.19.jar"
  content = data.local_file.hadoop_lzo_0_4_19_jar.content
}

data "local_file" "libgplcompression_a" {
  filename = "files/llap/encryption/libgplcompression.a"
}

resource "aws_s3_bucket_object" "libgplcompression_a" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/native/libgplcompression.a"
  content = data.local_file.libgplcompression_a.content
}

data "local_file" "libgplcompression_so" {
  filename = "files/llap/encryption/libgplcompression.so"
}

resource "aws_s3_bucket_object" "libgplcompression_so" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/native/libgplcompression.so"
  content = data.local_file.libgplcompression_so.content
}

data "local_file" "libgplcompression_so_0" {
  filename = "files/llap/encryption/libgplcompression.so.0"
}

resource "aws_s3_bucket_object" "libgplcompression_so_0" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/native/libgplcompression.so.0"
  content = data.local_file.libgplcompression_so_0.content
}

data "local_file" "libgplcompression_so_0_0_0" {
  filename = "files/llap/encryption/libgplcompression.so.0.0.0"
}

resource "aws_s3_bucket_object" "libgplcompression_so_0_0_0" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "emr/mongo_latest/files/llap/encryption/native/libgplcompression.so.0.0.0"
  content = data.local_file.libgplcompression_so_0_0_0.content
}
