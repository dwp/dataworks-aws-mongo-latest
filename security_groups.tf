resource "aws_security_group" "dataworks_aws_mongo_latest_master" {
  name                   = "dataworks_aws_mongo_latest Master"
  description            = "Contains rules for dataworks_aws_mongo_latest master nodes; most rules are injected by EMR, not managed by TF"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags                   = local.common_emr_tags
}

resource "aws_security_group" "dataworks_aws_mongo_latest_slave" {
  name                   = "dataworks_aws_mongo_latest Slave"
  description            = "Contains rules for dataworks_aws_mongo_latest slave nodes; most rules are injected by EMR, not managed by TF"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags                   = local.common_emr_tags
}

resource "aws_security_group" "dataworks_aws_mongo_latest_common" {
  name                   = "dataworks_aws_mongo_latest Common"
  description            = "Contains rules for both dataworks_aws_mongo_latest master and dataworks_aws_mongo_latest slave nodes"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags                   = local.common_emr_tags
}

resource "aws_security_group" "dataworks_aws_mongo_latest_emr_service" {
  name                   = "dataworks_aws_mongo_latest EMR Service"
  description            = "Contains rules for EMR service when managing the dataworks_aws_mongo_latest cluster; rules are injected by EMR, not managed by TF"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags                   = local.common_emr_tags
}

resource "aws_security_group_rule" "egress_https_to_vpc_endpoints" {
  description              = "Allow HTTPS traffic to VPC endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dataworks_aws_mongo_latest_common.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.interface_vpce_sg_id
}

resource "aws_security_group_rule" "ingress_https_vpc_endpoints_from_emr" {
  description              = "Allow HTTPS traffic from dataworks_aws_mongo_latest"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.dataworks_aws_mongo_latest_common.id
}

resource "aws_security_group_rule" "egress_https_s3_endpoint" {
  description       = "Allow HTTPS access to S3 via its endpoint"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.prefix_list_ids.s3]
  security_group_id = aws_security_group.dataworks_aws_mongo_latest_common.id
}

resource "aws_security_group_rule" "egress_http_s3_endpoint" {
  description       = "Allow HTTP access to S3 via its endpoint (YUM)"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  prefix_list_ids   = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.prefix_list_ids.s3]
  security_group_id = aws_security_group.dataworks_aws_mongo_latest_common.id
}


resource "aws_security_group_rule" "egress_internet_proxy" {
  description              = "Allow Internet access via the proxy (for ACM-PCA)"
  type                     = "egress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.internet_proxy.sg
  security_group_id        = aws_security_group.dataworks_aws_mongo_latest_common.id
}

resource "aws_security_group_rule" "ingress_internet_proxy" {
  description              = "Allow proxy access from dataworks_aws_mongo_latest"
  type                     = "ingress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.dataworks_aws_mongo_latest_common.id
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.internet_proxy.sg
}

resource "aws_security_group_rule" "egress_dataworks_aws_mongo_latest_to_dks" {
  description       = "Allow requests to the DKS"
  type              = "egress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = data.terraform_remote_state.crypto.outputs.dks_subnet.cidr_blocks
  security_group_id = aws_security_group.dataworks_aws_mongo_latest_common.id
}

resource "aws_security_group_rule" "ingress_to_dks" {
  provider    = aws.crypto
  description = "Allow inbound requests to DKS from dataworks_aws_mongo_latest"
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 8443
  to_port     = 8443

  cidr_blocks = data.terraform_remote_state.internal_compute.outputs.dataworks_aws_mongo_latest_subnet.cidr_blocks

  security_group_id = data.terraform_remote_state.crypto.outputs.dks_sg_id[local.environment]
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html#emr-sg-elasticmapreduce-sa-private
resource "aws_security_group_rule" "emr_service_ingress_master" {
  description              = "Allow EMR master nodes to reach the EMR service"
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.dataworks_aws_mongo_latest_master.id
  security_group_id        = aws_security_group.dataworks_aws_mongo_latest_emr_service.id
}


# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_master_to_core_egress_tcp" {
  description              = "Allow master nodes to send TCP traffic to core nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.dataworks_aws_mongo_latest_slave.id
  security_group_id        = aws_security_group.dataworks_aws_mongo_latest_master.id
}

# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_core_to_master_egress_tcp" {
  description              = "Allow core nodes to send TCP traffic to master nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.dataworks_aws_mongo_latest_master.id
  security_group_id        = aws_security_group.dataworks_aws_mongo_latest_slave.id
}

# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_core_to_core_egress_tcp" {
  description       = "Allow core nodes to send TCP traffic to other core nodes"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.dataworks_aws_mongo_latest_slave.id
}

# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_master_to_core_egress_udp" {
  description              = "Allow master nodes to send UDP traffic to core nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.dataworks_aws_mongo_latest_slave.id
  security_group_id        = aws_security_group.dataworks_aws_mongo_latest_master.id
}

# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_core_to_master_egress_udp" {
  description              = "Allow core nodes to send UDP traffic to master nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.dataworks_aws_mongo_latest_master.id
  security_group_id        = aws_security_group.dataworks_aws_mongo_latest_slave.id
}

# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_core_to_core_egress_udp" {
  description       = "Allow core nodes to send UDP traffic to other core nodes"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  self              = true
  security_group_id = aws_security_group.dataworks_aws_mongo_latest_slave.id
}

output "dataworks_aws_mongo_latest_common_sg" {
  value = aws_security_group.dataworks_aws_mongo_latest_common
}
