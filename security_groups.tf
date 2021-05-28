resource "aws_security_group" "mongo_latest_master" {
  name                   = "Mongo Latest Master"
  description            = "Contains rules for Mongo Latest master nodes; most rules are injected by EMR, not managed by TF"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags                   = local.common_emr_tags
}

resource "aws_security_group" "mongo_latest_slave" {
  name                   = "Mongo Latest Slave"
  description            = "Contains rules for Mongo Latest slave nodes; most rules are injected by EMR, not managed by TF"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags                   = local.common_emr_tags
}

resource "aws_security_group" "mongo_latest_common" {
  name                   = "Mongo Latest Common"
  description            = "Contains rules for both Mongo Latest master and Mongo Latest slave nodes"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags                   = local.common_emr_tags
}

resource "aws_security_group" "mongo_latest_emr_service" {
  name                   = "Mongo Latest EMR Service"
  description            = "Contains rules for EMR service when managing the Mongo Latest cluster; rules are injected by EMR, not managed by TF"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags                   = local.common_emr_tags
}

resource "aws_security_group_rule" "egress_https_to_vpc_endpoints" {
  description              = "Allow HTTPS traffic to VPC endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mongo_latest_common.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.interface_vpce_sg_id
}

resource "aws_security_group_rule" "ingress_https_vpc_endpoints_from_emr" {
  description              = "Allow HTTPS traffic from Mongo Latest"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "egress_https_s3_endpoint" {
  description       = "Allow HTTPS access to S3 via its endpoint"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.prefix_list_ids.s3]
  security_group_id = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "egress_http_s3_endpoint" {
  description       = "Allow HTTP access to S3 via its endpoint (YUM)"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  prefix_list_ids   = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.prefix_list_ids.s3]
  security_group_id = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "egress_https_dynamodb_endpoint" {
  description       = "Allow HTTPS access to DynamoDB via its endpoint (EMRFS)"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.prefix_list_ids.dynamodb]
  security_group_id = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "egress_internet_proxy" {
  description              = "Allow Internet access via the proxy (for ACM-PCA)"
  type                     = "egress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.internet_proxy.sg
  security_group_id        = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "ingress_internet_proxy" {
  description              = "Allow proxy access from Mongo Latest"
  type                     = "ingress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mongo_latest_common.id
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.internet_proxy.sg
}

resource "aws_security_group_rule" "egress_hbase_zookeeper" {
  description              = "Allow Ingest-HBase Zookeeper requests"
  type                     = "egress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.aws_emr_cluster.common_sg_id
  security_group_id        = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "ingress_hbase_zookeeper" {
  description              = "Allow Mongo Latest requests to ZooKeeper"
  type                     = "ingress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mongo_latest_common.id
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.aws_emr_cluster.common_sg_id
}

resource "aws_security_group_rule" "egress_hbase_master" {
  description              = "Allow Ingest-HBase Master requests"
  type                     = "egress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.aws_emr_cluster.common_sg_id
  security_group_id        = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "ingress_hbase_master" {
  description              = "Allow Mongo Latest requests to HBase Master"
  type                     = "ingress"
  from_port                = 16000
  to_port                  = 16000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mongo_latest_common.id
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.aws_emr_cluster.common_sg_id
}

resource "aws_security_group_rule" "egress_hbase_regionserver" {
  description              = "Allow Ingest-HBase RegionServer traffic"
  type                     = "egress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.aws_emr_cluster.common_sg_id
  security_group_id        = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "ingress_hbase_regionserver" {
  description              = "Allow Mongo Latest requests to HBase Region Server"
  type                     = "ingress"
  from_port                = 16020
  to_port                  = 16020
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mongo_latest_common.id
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.aws_emr_cluster.common_sg_id
}

resource "aws_security_group_rule" "egress_mongo_latest_to_dks" {
  description       = "Allow requests to the DKS"
  type              = "egress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = data.terraform_remote_state.crypto.outputs.dks_subnet.cidr_blocks
  security_group_id = aws_security_group.mongo_latest_common.id
}

resource "aws_security_group_rule" "ingress_to_dks" {
  provider    = aws.crypto
  description = "Allow inbound requests to DKS from Mongo Latest"
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 8443
  to_port     = 8443

  cidr_blocks = data.terraform_remote_state.internal_compute.outputs.mongo_latest_subnet.cidr_blocks

  security_group_id = data.terraform_remote_state.crypto.outputs.dks_sg_id[local.environment]
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html#emr-sg-elasticmapreduce-sa-private
resource "aws_security_group_rule" "emr_service_ingress_master" {
  description              = "Allow EMR master nodes to reach the EMR service"
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mongo_latest_master.id
  security_group_id        = aws_security_group.mongo_latest_emr_service.id
}


# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_master_to_core_egress_tcp" {
  description              = "Allow master nodes to send TCP traffic to core nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mongo_latest_slave.id
  security_group_id        = aws_security_group.mongo_latest_master.id
}

# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_core_to_master_egress_tcp" {
  description              = "Allow core nodes to send TCP traffic to master nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mongo_latest_master.id
  security_group_id        = aws_security_group.mongo_latest_slave.id
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
  security_group_id = aws_security_group.mongo_latest_slave.id
}

# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_master_to_core_egress_udp" {
  description              = "Allow master nodes to send UDP traffic to core nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.mongo_latest_slave.id
  security_group_id        = aws_security_group.mongo_latest_master.id
}

# The EMR service will automatically add the ingress equivalent of this rule,
# but doesn't inject this egress counterpart
resource "aws_security_group_rule" "emr_core_to_master_egress_udp" {
  description              = "Allow core nodes to send UDP traffic to master nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "udp"
  source_security_group_id = aws_security_group.mongo_latest_master.id
  security_group_id        = aws_security_group.mongo_latest_slave.id
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
  security_group_id = aws_security_group.mongo_latest_slave.id
}

# DW-4134 - Rule for the dev Workspaces, gated to dev - "Ganglia"
resource "aws_security_group_rule" "emr_server_ingress_workspaces_master_80" {
  count             = local.environment == "development" ? 1 : 0
  description       = "Allow WorkSpaces (internal-compute VPC) access to Ganglia"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.cidr_block]
  security_group_id = aws_security_group.mongo_latest_master.id
}

# DW-4134 - Rule for the dev Workspaces, gated to dev - "Hbase"
resource "aws_security_group_rule" "emr_server_ingress_workspaces_master_hbase" {
  count             = local.environment == "development" ? 1 : 0
  description       = "Allow WorkSpaces (internal-compute VPC) access to Hbase"
  type              = "ingress"
  from_port         = 16010
  to_port           = 16010
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.cidr_block]
  security_group_id = aws_security_group.mongo_latest_master.id
}

# DW-4134 - Rule for the dev Workspaces, gated to dev - "Spark"
resource "aws_security_group_rule" "emr_server_ingress_workspaces_master_spark" {
  count             = local.environment == "development" ? 1 : 0
  description       = "Allow WorkSpaces (internal-compute VPC) access to Spark"
  type              = "ingress"
  from_port         = 18080
  to_port           = 18080
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.cidr_block]
  security_group_id = aws_security_group.mongo_latest_master.id
}

# DW-4134 - Rule for the dev Workspaces, gated to dev - "Yarn NodeManager"
resource "aws_security_group_rule" "emr_server_ingress_workspaces_master_yarn_nm" {
  count             = local.environment == "development" ? 1 : 0
  description       = "Allow WorkSpaces (internal-compute VPC) access to Yarn NodeManager"
  type              = "ingress"
  from_port         = 8042
  to_port           = 8042
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.cidr_block]
  security_group_id = aws_security_group.mongo_latest_master.id
}

# DW-4134 - Rule for the dev Workspaces, gated to dev - "Yarn ResourceManager"
resource "aws_security_group_rule" "emr_server_ingress_workspaces_master_yarn_rm" {
  count             = local.environment == "development" ? 1 : 0
  description       = "Allow WorkSpaces (internal-compute VPC) access to Yarn ResourceManager"
  type              = "ingress"
  from_port         = 8088
  to_port           = 8088
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.cidr_block]
  security_group_id = aws_security_group.mongo_latest_master.id
}

# DW-4134 - Rule for the dev Workspaces, gated to dev - "Region Server"
resource "aws_security_group_rule" "emr_server_ingress_workspaces_slave_region_server" {
  count             = local.environment == "development" ? 1 : 0
  description       = "Allow WorkSpaces (internal-compute VPC) access to Region Server"
  type              = "ingress"
  from_port         = 16030
  to_port           = 16030
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.cidr_block]
  security_group_id = aws_security_group.mongo_latest_slave.id
}
