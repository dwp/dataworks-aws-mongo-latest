#!/bin/bash
(
    INSTANCE_ROLE=$(jq .instanceRole /mnt/var/lib/info/extraInstanceData.json)

    #only log on master to avoid duplication
    if [[ "$INSTANCE_ROLE" != '"MASTER"' ]]; then
        exit 0
    fi

    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_mongo_latest_message "$${1}" "update_dynamo.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

  log_wrapper_message "Start running update_dynamo.sh Shell"

  STEP_DETAILS_DIR=/emr/instance-controller/lib/info
  TMP_STEP_JSON_OUTPUT_LOCATION=$STEP_DETAILS_DIR/tmp
  STEP_JSON_OUTPUT_LOCATION=$STEP_DETAILS_DIR/steps
  mkdir -p $TMP_STEP_JSON_OUTPUT_LOCATION $STEP_JSON_OUTPUT_LOCATION

  CORRELATION_ID_FILE=/opt/emr/correlation_id.txt
  SNAPSHOT_TYPE_FILE=/opt/emr/snapshot_type.txt
  OUTPUT_LOCATION_FILE=/opt/emr/output_location.txt
  EXPORT_DATE_FILE=/opt/emr/export_date.txt
  DATE=$(date '+%Y-%m-%d')
  CLUSTER_ID=$(jq '.jobFlowId' < /mnt/var/lib/info/job-flow.json)
  CLUSTER_ID="$${CLUSTER_ID//\"}"

  FAILED_STATUS="FAILED"
  COMPLETED_STATUS="COMPLETED"
  IN_PROGRESS_STATUS="IN_PROGRESS"
  CANCELLED_STATUS="CANCELLED"
  RUNNING_STATUS="RUNNING"

  FINAL_STEP_NAME="${dynamodb_final_step}"

  while [[ ! -f "$CORRELATION_ID_FILE" ]] && [[ ! -f "$SNAPSHOT_TYPE_FILE" ]] && [[ ! -f "$EXPORT_DATE_FILE" ]]
  do
    sleep 5
  done

  CORRELATION_ID=$(cat $CORRELATION_ID_FILE)
  SNAPSHOT_TYPE=$(cat $SNAPSHOT_TYPE_FILE)
  EXPORT_DATE=$(cat $EXPORT_DATE_FILE)
  DATA_PRODUCT="MONGO_LATEST"

  if [[ -z "$EXPORT_DATE" ]]; then
    log_wrapper_message "Export date from file was empty, so defaulting to today's date"
    EXPORT_DATE="$DATE"
  fi

  get_ttl() {
      TIME_NOW=$(($(date +'%s * 1000 + %-N / 1000000')))
      echo $((TIME_NOW + 604800000))
  }

  get_output_location() {
    OUTPUT_LOCATION="NOT_SET"

    if [[ -f "$OUTPUT_LOCATION_FILE" ]]; then
      OUTPUT_LOCATION=$(cat $OUTPUT_LOCATION_FILE)
    fi

    echo "$OUTPUT_LOCATION"
  }

  MAX_RETRY=10
  processed_files=()
  dynamo_update_item() {
    current_step="$1"
    status="$2"
    run_id="$3"

    ttl_value=$(get_ttl)
    output_location_value=$(get_output_location)

    log_wrapper_message "Updating DynamoDB with Correlation_Id: $CORRELATION_ID, DataProduct: $DATA_PRODUCT, Date: $EXPORT_DATE, Cluster_Id: $CLUSTER_ID, S3_Prefix_Analytical_DataSet: $output_location_value, Snapshot_Type: $SNAPSHOT_TYPE, TimeToExist: $ttl_value, CurrentStep: $current_step, Status: $status, Run_Id: $run_id"

    update_expression="SET #d = :s, Cluster_Id = :v, Snapshot_Type = :x, TimeToExist = :z"
    expression_values="\":s\": {\"S\":\"$EXPORT_DATE\"}, \":v\": {\"S\":\"$CLUSTER_ID\"}, \":x\": {\"S\":\"$SNAPSHOT_TYPE\"}, \":z\": {\"N\":\"$ttl_value\"}"
    expression_names="\"#d\":\"Date\""

    if [[ -n "$current_step" ]] && [[ "$current_step" != "NOT_SET" ]]; then
        update_expression="$update_expression, CurrentStep = :y"
        expression_values="$expression_values, \":y\": {\"S\":\"$current_step\"}"
    fi

    if [[ -n "$status" ]] && [[ "$status" != "NOT_SET" ]]; then
        update_expression="$update_expression, #a = :u"
        expression_values="$expression_values, \":u\": {\"S\":\"$status\"}"
        expression_names="$expression_names, \"#a\":\"Status\""
    fi

    if [[ -n "$run_id" ]] && [[ "$run_id" != "NOT_SET" ]]; then
        update_expression="$update_expression, Run_Id = :t"
        expression_values="$expression_values, \":t\": {\"N\":\"$run_id\"}"
    fi

    if [[ -n "$output_location_value" ]] && [[ "$output_location_value" != "NOT_SET" ]]; then
        update_expression="$update_expression, S3_Prefix_Analytical_DataSet = :b"
        expression_values="$expression_values, \":b\": {\"S\":\"$output_location_value\"}"
    fi

    $(which aws) dynamodb update-item --table-name "${dynamodb_table_name}" \
        --key "{\"Correlation_Id\":{\"S\":\"$CORRELATION_ID\"},\"DataProduct\":{\"S\":\"$DATA_PRODUCT\"}}" \
        --update-expression "$update_expression" \
        --expression-attribute-values "{$expression_values}" \
        --expression-attribute-names "{$expression_names}"
  }

  check_step_dir() {
    cd "$STEP_DETAILS_DIR" || exit
    #shellcheck disable=SC2231
    for i in $STEP_JSON_OUTPUT_LOCATION/*.json; do # We want wordsplitting here
      #shellcheck disable=SC2076
      if [[ "$${processed_files[@]}" =~ "$${i}" ]]; then # We do not want a REGEX check here so it is ok
        continue
      fi
      RETRY_COUNT=0
      state=$(jq -r '.state' "$i")
      while [[ "$state" != "$COMPLETED_STATUS" ]]; do
        step_script_name=$(jq -r '.args[0]' "$i")
        CURRENT_STEP=$(echo "$step_script_name" | sed 's:.*/::' | cut -f 1 -d '.')
        state=$(jq -r '.state' "$i")
        if [[ -n "$state" ]] && [[ -n "$CURRENT_STEP" ]]; then
          if [[ "$state" == "$FAILED_STATUS" ]] || [[ "$state" == "$CANCELLED_STATUS" ]]; then
            log_wrapper_message "Failed step. Step Name: $CURRENT_STEP, Step status: $state"
            dynamo_update_item "$CURRENT_STEP" "$FAILED_STATUS" "NOT_SET"
            exit 0
          fi
          if [[ "$CURRENT_STEP" == "$FINAL_STEP_NAME" ]] && [[ "$state" == "$COMPLETED_STATUS" ]]; then
            dynamo_update_item "$CURRENT_STEP" "$COMPLETED_STATUS" "NOT_SET"
            log_wrapper_message "All steps completed. Final step Name: $CURRENT_STEP, Step status: $state"
            exit 0
          fi
          if [[ "$PREVIOUS_STATE" != "$state" ]] && [[ "$PREVIOUS_STEP" != "$CURRENT_STEP" ]]; then
            dynamo_update_item "$CURRENT_STEP" "NOT_SET" "NOT_SET"
            log_wrapper_message "Successful step. Last step name: $PREVIOUS_STEP, Last step status: $PREVIOUS_STATE, Current step name: $CURRENT_STEP, Current step status: $state"
            processed_files+=( "$i" )
          else
            # refresh json files
            build_step_json_file
            sleep 0.2
          fi
        else
          if [[ "$RETRY_COUNT" -ge "$MAX_RETRY" ]]; then
            log_wrapper_message "Could not parse one or more json attributes from $i. Last Step Name: $PREVIOUS_STEP. Last State Name: $PREVIOUS_STATE."
            dynamo_update_item "$CURRENT_STEP" "$FAILED_STATUS" "NOT_SET"
            exit 1
          fi
          RETRY_COUNT=$((RETRY_COUNT+1))
          log_wrapper_message "Sleeping... Failed reading step file $RETRY_COUNT times. Could not parse one or more json attributes from $i. Last Step Name: $PREVIOUS_STEP. Last State Name: $PREVIOUS_STATE."
          sleep 1
        fi
        PREVIOUS_STATE="$state"
        PREVIOUS_STEP="$CURRENT_STEP"
      done
    done
    check_step_dir
  }

  build_step_json_file() {
    cd "$STEP_DETAILS_DIR" || { log_wrapper_message "Issue encountered while changing the working directory to $STEP_DETAILS_DIR"; exit; }

    # step sequence to a flat file
    grep -A 1 -E '^\s*stepEntities {' job-flow-state.txt | grep sequence: | sed 's/^[ \t]*//g' > $TMP_STEP_JSON_OUTPUT_LOCATION/seq.txt

    # step argument to a flat file (this always aligns/matches with step sequence)
    grep -A 2 -E 'id: "s-' job-flow-state.txt | grep 'arg: ' | sed 's/^[ \t]*//g' | tr -d '"' | cut -c 6- > $TMP_STEP_JSON_OUTPUT_LOCATION/args.txt

    # step-ids to a flat file (required to get step status, no other use)
    while IFS= read -r line;
    do
        grep -A 2 -E "$line$" job-flow-state.txt | grep 'id: "s-'
    done < $TMP_STEP_JSON_OUTPUT_LOCATION/seq.txt |  sed 's/^[ \t]*//g' | cut -c 6- | tr -d '"' > $TMP_STEP_JSON_OUTPUT_LOCATION/ids.txt

    # step state to a flat file
    while IFS= read -r line;
    do
        grep -A 2 -E "$line" job-flow-state.txt | grep 'state: '
    done < $TMP_STEP_JSON_OUTPUT_LOCATION/ids.txt |  sed 's/^[ \t]*//g' | cut -c 8-  > $TMP_STEP_JSON_OUTPUT_LOCATION/state.txt

    # re-do sequence file - to remove 'sequence: ' prefix
    grep -A 1 -E '^\s*stepEntities {' job-flow-state.txt | grep sequence: | sed 's/^[ \t]*//g' | cut -c 11- > $TMP_STEP_JSON_OUTPUT_LOCATION/seq.txt

    STEP_COUNT=$(cat $TMP_STEP_JSON_OUTPUT_LOCATION/seq.txt | wc -l)

    # ensure that all flat file line count matches before continuing
    if [[ $STEP_COUNT != $(cat $TMP_STEP_JSON_OUTPUT_LOCATION/ids.txt | wc -l) ]] || [[ $STEP_COUNT != $(cat $TMP_STEP_JSON_OUTPUT_LOCATION/state.txt | wc -l) ]] || [[ $STEP_COUNT != $(cat $TMP_STEP_JSON_OUTPUT_LOCATION/args.txt | wc -l) ]]; then
        log_wrapper_message "An issue encountered while building step json. Line counts in one or more step falt files do not match!"
        dynamo_update_item "NOT_SET" "$FAILED_STATUS" "NOT_SET"
        exit 1
    fi

    # (re)write id.json
    CURRENT_STEP_COUNT=1
    while [[ "$CURRENT_STEP_COUNT" -le "$STEP_COUNT" ]]; do

        printf '{\n  "id": %s,\n  "args": [\n    "%s"\n  ],\n  "state": "%s"\n}\n' "$(sed "$CURRENT_STEP_COUNT!d" < "$TMP_STEP_JSON_OUTPUT_LOCATION/seq.txt")" "$(sed "$CURRENT_STEP_COUNT!d" < "$TMP_STEP_JSON_OUTPUT_LOCATION/args.txt")" "$(sed "$CURRENT_STEP_COUNT!d" < "$TMP_STEP_JSON_OUTPUT_LOCATION/state.txt")" > "$TMP_STEP_JSON_OUTPUT_LOCATION/$CURRENT_STEP_COUNT.json"

        # move json that has completed & running state to step watch dir
        if grep -q "$COMPLETED_STATUS" "$TMP_STEP_JSON_OUTPUT_LOCATION/$CURRENT_STEP_COUNT.json" || grep -q "$RUNNING_STATUS" "$TMP_STEP_JSON_OUTPUT_LOCATION/$CURRENT_STEP_COUNT.json"; then
            mv "$TMP_STEP_JSON_OUTPUT_LOCATION/$CURRENT_STEP_COUNT.json" "$STEP_JSON_OUTPUT_LOCATION/$CURRENT_STEP_COUNT.json"
        fi
          CURRENT_STEP_COUNT=$((CURRENT_STEP_COUNT+1))
        sleep 0.5
    done
  }

  #Check if row for this correlation ID already exists - in which case we need to increment the Run_Id
  #shellcheck disable=SC2086
  response=$(aws dynamodb get-item --table-name "${dynamodb_table_name}" --key '{"Correlation_Id": {"S": "'$CORRELATION_ID'"}, "DataProduct": {"S": "'$DATA_PRODUCT'"}}') # Quoting is fine, has to be this way for DDB
  if [[ -z "$response" ]]; then
    dynamo_update_item "NOT_SET" "$IN_PROGRESS_STATUS" "1"
  else
    LAST_STATUS=$(echo "$response" | jq -r .'Item.Status.S')
    log_wrapper_message "Status from previous run $LAST_STATUS"
    if [[ "$LAST_STATUS" == "$FAILED_STATUS" ]]; then
      log_wrapper_message "Previous failed status found, creating step_to_start_from.txt"
      CURRENT_STEP=$(echo "$response" | jq -r .'Item.CurrentStep.S')
      echo "$CURRENT_STEP" >> /opt/emr/step_to_start_from.txt
    fi

    CURRENT_RUN_ID=$(echo "$response" | jq -r .'Item.Run_Id.N')
    NEW_RUN_ID=$((CURRENT_RUN_ID+1))
    dynamo_update_item "NOT_SET" "$IN_PROGRESS_STATUS" "$NEW_RUN_ID"
  fi
  log_wrapper_message "Updating DynamoDB with CORRELATION_ID: $CORRELATION_ID and RUN_ID: $NEW_RUN_ID"

  # wait for step json to be created
  READY_TO_BUILD_JSON=0
  while [[ ! "$READY_TO_BUILD_JSON" == 1 ]]; do
      if grep -q 'stepEntities' "$STEP_DETAILS_DIR/job-flow-state.txt" ; then
          READY_TO_BUILD_JSON=1
          sleep 5
          build_step_json_file
          log_wrapper_message "Step metadata are now available ..."
      else
          log_wrapper_message "Waiting for step metadata  ..."
          sleep 10
      fi
  done

  #kick off loop to process all step files
  check_step_dir

) >> /var/log/mongo_latest/update_dynamo_sh.log 2>&1
