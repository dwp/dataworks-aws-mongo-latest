#!/bin/bash

sudo mkdir -p /var/log/mongo_latest
sudo mkdir -p /var/log/aws_cbol_data
sudo mkdir -p /var/log/aws_payment_timelines
sudo mkdir -p /opt/emr
sudo mkdir -p /opt/custom_jars
sudo mkdir -p /opt/shared
sudo mkdir -p /var/ci
sudo chown hadoop:hadoop /var/log/mongo_latest
sudo chown hadoop:hadoop /var/log/aws_cbol_data
sudo chown hadoop:hadoop /var/log/aws_payment_timelines
sudo chown hadoop:hadoop /opt/emr
sudo chown hadoop:hadoop /opt/custom_jars
sudo chown hadoop:hadoop /opt/shared
sudo chown hadoop:hadoop /var/ci
export LOG_LEVEL="${LOG_LEVEL}"

echo "${VERSION}" > /opt/emr/version
echo "${LOG_LEVEL}" > /opt/emr/log_level
echo "${ENVIRONMENT_NAME}" > /opt/emr/environment

# Download the logging scripts
$(which aws) s3 cp "${S3_COMMON_LOGGING_SHELL}"  /opt/shared/common_logging.sh
$(which aws) s3 cp "${S3_LOGGING_SHELL}"         /opt/emr/logging.sh
$(which aws) s3 cp "${DECRYPTION_JAR}"           /opt/custom_jars/encryption-materials-provider-all.jar

# Set permissions
chmod u+x /opt/shared/common_logging.sh
chmod u+x /opt/emr/logging.sh
chmod u+x /opt/custom_jars/encryption-materials-provider-all.jar

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_mongo_latest_message "$${1}" "download_scripts.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    log_wrapper_message "Downloading & install latest bootstrap and steps scripts"
    $(which aws) s3 cp --recursive "${scripts_location}/" /var/ci/ --include "*.sh"

    log_wrapper_message "Apply recursive execute permissions to the folder"
    sudo chmod --recursive a+rx /var/ci

    log_wrapper_message "Script downloads completed"

)  >> /var/log/mongo_latest/download_scripts.log 2>&1
