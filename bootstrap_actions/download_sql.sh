#!/bin/bash

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_mongo_latest_message "$${1}" "download_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    REPOSITORY_NAME="$1"
    VERSION="$2"

    SCRIPT_DIR="/opt/emr/$REPOSITORY_NAME"

    echo "Download & install latest mongo latest scripts"
    log_wrapper_message "Downloading & install $REPOSITORY_NAME scripts"

    URL="s3://${s3_artefact_bucket_id}/$REPOSITORY_NAME/$REPOSITORY_NAME-$VERSION.zip"
    $(which aws) s3 cp "$URL" "/opt/emr/"

    echo "VERSION: $VERSION"
    log_wrapper_message "$REPOSITORY_NAME version: $VERSION"

    echo "SCRIPT_DOWNLOAD_URL: $URL"
    log_wrapper_message "script_download_url: $URL"

    echo "Unzipping location: $SCRIPT_DIR"
    log_wrapper_message "script unzip location: $SCRIPT_DIR"

    echo "$version" > /opt/emr/version
    echo "${log_level}" > /opt/emr/log_level
    echo "${environment_name}" > /opt/emr/environment

    echo "START_UNZIPPING ......................"
    log_wrapper_message "start unzipping ......................."

    unzip "/opt/emr/$REPOSITORY_NAME-$VERSION.zip" -d "$SCRIPT_DIR"

    echo "FINISHED UNZIPPING ......................"
    log_wrapper_message "finished unzipping ......................."

)  >> /var/log/mongo_latest/download_sql.log 2>&1

