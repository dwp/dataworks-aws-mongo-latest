#!/bin/bash

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_mongo_latest_message "$${1}" "download_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    REPOSITORY_NAME="$1"
    VERSION="$2"
    LOCAL_FOLDER="$3"

    SCRIPT_DIR="$LOCAL_FOLDER/$REPOSITORY_NAME"

    echo "Download & install latest $REPOSITORY_NAME scripts"
    log_wrapper_message "Downloading & install $REPOSITORY_NAME scripts"

    URL="s3://${s3_artefact_bucket_id}/$REPOSITORY_NAME/$REPOSITORY_NAME-$VERSION.zip"
    $(which aws) s3 cp "$URL" "$LOCAL_FOLDER/"

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

    unzip "$LOCAL_FOLDER/$REPOSITORY_NAME-$VERSION.zip" -d "$SCRIPT_DIR"

    echo "FINISHED UNZIPPING ......................"
    log_wrapper_message "finished unzipping ......................."

    echo "Setting shell scripts as executable"
    log_wrapper_message "Setting shell scripts as executable"

    find "$SCRIPT_DIR" -type f -name "*.sh" -print0 | xargs -0 chmod 755

)  >> /var/log/mongo_latest/download_sql.log 2>&1

