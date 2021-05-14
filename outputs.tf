output "mongo_latest_common_sg" {
  value = aws_security_group.mongo_latest_common
}

output "mongo_latest_emr_launcher_lambda" {
  value = aws_lambda_function.mongo_latest_emr_launcher
}
