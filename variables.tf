variable "truststore_aliases" {
  description = "comma seperated truststore aliases"
  type        = list(string)
  default     = ["dataworks_root_ca", "dataworks_mgt_root_ca"]
}

variable "emr_ami_id" {
  description = "AMI ID to use for the HBase EMR nodes"
  default     = "ami-0a5d042ae876f72ff"
}

variable "emr_release" {
  default = {
    development = "6.2.0"
    qa          = "6.2.0"
    integration = "6.2.0"
    preprod     = "6.2.0"
    production  = "6.2.0"
  }
}

variable "emr_instance_type_master" {
  default = {
    development = "m5.4xlarge"
    qa          = "m5.4xlarge"
    integration = "m5.4xlarge"
    preprod     = "m5.16xlarge"
    production  = "m5.16xlarge"
  }
}

variable "emr_instance_type_core_one" {
  default = {
    development = "m5.4xlarge"
    qa          = "m5.4xlarge"
    integration = "m5.4xlarge"
    preprod     = "m5.16xlarge"
    production  = "m5.16xlarge"
  }
}

# Count of instances
variable "emr_core_instance_count" {
  default = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "39"
    production  = "39"
  }
}
