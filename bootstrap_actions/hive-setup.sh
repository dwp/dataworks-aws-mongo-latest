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

    log_wrapper_message "Enable yarn fast launch for LLAP"
    sudo sed -i "s/.require.Enable Yarn fastlaunch.*/ require => [ Exec['Enable Yarn fastlaunch'] ],/g" /var/aws/emr/bigtop-deploy/puppet/modules/hadoop_hive/manifests/init.pp

) >> /var/log/mongo_latest/hive_setup.log 2>&1
