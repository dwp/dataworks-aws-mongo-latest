data "aws_secretsmanager_secret_version" "terraform_secrets" {
  provider  = aws.management_dns
  secret_id = "/concourse/dataworks/terraform"
}

resource "aws_service_discovery_service" "mongo_latest_services" {
  name = "mongo_latest-pushgateway"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.mongo_latest_services.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  tags = {
    Name = "mongo_latest_services"
  }
}

resource "aws_service_discovery_private_dns_namespace" "mongo_latest_services" {
  name = "${local.environment}.mongo_latest.services.${jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary)["dataworks_domain_name"]}"
  vpc  = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags = {
    Name = "mongo_latest_services"
  }
}
