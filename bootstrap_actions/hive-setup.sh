#!/bin/bash
set -euo pipefail
(
    # Import the logging functions
    source /opt/emr/logging.sh
    
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_mongo_latest_message "$1" "hive-setup.sh" "$$" "Running as: $USER"
    }

    log_wrapper_message "Copying maria db jar to spark jars folder"
    sudo mkdir -p /usr/lib/spark/jars/
    sudo cp /usr/share/java/mariadb-connector-java.jar /usr/lib/spark/jars/

    log_wrapper_message "Setting up EMR steps folder"
    sudo mkdir -p /opt/emr/steps
    sudo chown hadoop:hadoop /opt/emr/steps

    log_wrapper_message "Copying decryption jar to EMR jars folder"
    sudo mkdir -p /opt/emr/custom_jars
    sudo cp /opt/emr/encryption-materials-provider-all.jar /opt/emr/custom_jars/

    log_wrapper_message "Copying compression jars to EMR jars folder"
    sudo cp /usr/lib/hadoop-lzo/lib/hadoop-lzo-0.4.19.jar /opt/emr/custom_jars/
    sudo cp /usr/lib/hadoop-lzo/lib/hadoop-lzo.jar /opt/emr/custom_jars/
    sudo cp -r /usr/lib/hadoop-lzo/lib/native/ /opt/emr/custom_jars/

) >> /var/log/mongo_latest/hive_setup.log 2>&1


