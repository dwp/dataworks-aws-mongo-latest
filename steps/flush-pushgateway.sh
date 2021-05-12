#!/bin/bash

# This script waits for a fixed period to give the metrics scraper enough
# time to collect Mongo Latest metrics. It then deletes all of Mongo Latests metrics so that
# the scraper doesn't continually gather stale metrics long past Mongo Latest's termination.

(
    # Import the logging functions
    source /opt/emr/logging.sh
    
    # Import and execute resume step function
    source /opt/emr/resume_step.sh
    
    function log_wrapper_message() {
        log_mongo_latest_message "$${1}" "flush-pushgateway.sh" "Running as: ,$USER"
    }
    
    log_wrapper_message "Sleeping for 3m"
    
    sleep 180 # scrape interval is 60, scrape timeout is 10, 5 for the pot
    
    log_wrapper_message "Flushing the Mongo Latest pushgateway"
    curl -X PUT "http://${mongo_latest_pushgateway_hostname}:9091/api/v1/admin/wipe"
    log_wrapper_message "Done flushing the Mongo Latest pushgateway"
    
) >> /var/log/mongo_latest/flush-pushgateway.log 2>&1
