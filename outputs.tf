output "mongo_latest_common_sg" {
  value = aws_security_group.mongo_latest_common
}

output "mongo_latest_emr_launcher_lambda" {
  value = aws_lambda_function.mongo_latest_emr_launcher
}

output "private_dns" {
  value = {
    mongo_latest_service_discovery_dns = aws_service_discovery_private_dns_namespace.mongo_latest_services
    mongo_latest_service_discovery     = aws_service_discovery_service.mongo_latest_services
  }
}
