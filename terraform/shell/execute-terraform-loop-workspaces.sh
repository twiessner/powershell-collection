#!/usr/bin/env bash

# Loop over all terraform workspaces and run terraform apply
#
# Example
# ./execute-terraform-loop-workspaces.sh --upstream
#
# Parameters
#   --logdir=""               (Set folder for the apply logs)
#   --tf_workspaces_ignore="" (Space separated list of workspaces to ignore)
#   --upstream=""             (Should we run terraform init -upgrde?)
#
# When no parameters are defined, you will be ask for some inputs


for i in "$@"; do
  case $i in
    --logdir=*)
      LOG_DIR="${i#*=}"
      shift # past argument=value
      ;;
    --tf_workspaces_ignore=*)
      TF_WORKSPACE_IGNORE="${i#*=}"
      shift # past argument=value
      ;;
    --upstream)
      UPSTREAM=YES
      shift # past argument with no value
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

function exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    LIST_WHITESPACES=`echo $LIST | tr "$DELIMITER" " "`
    for x in $LIST_WHITESPACES; do
        if [ "$x" = "$VALUE" ]; then
            return 0
        fi
    done
    return 1
}

if [ -z "$LOG_DIR" ]; then
   read -p "Enter the folder to save the log files [tf_output_logs]: " LOG_DIR
   LOG_DIR=${LOG_DIR:-tf_output_logs}
fi

if [ -z "$TF_WORKSPACE_IGNORE" ]; then
   read -p "Enter the workspace to ignore (space separated) []: " TF_WORKSPACE_IGNORE
   TF_WORKSPACE_IGNORE=${TF_WORKSPACE_IGNORE:-""}
fi

rm -rf "${LOG_DIR}"
mkdir -p "${LOG_DIR}"

if [ ! -z $UPSTREAM ]; then
	terraform init -upgrade
else
	terraform init
fi

for WORKSPACE in $(terraform workspace list|sed 's/*//g'); do
  if exists_in_list "${TF_WORKSPACE_IGNORE}" " " "$WORKSPACE"; then
    continue;
  fi
  echo $WORKSPACE
  terraform workspace select "$WORKSPACE"

  terraform apply -no-color -auto-approve 2>&1 | tee "${LOG_DIR}/apply_${WORKSPACE}.log"
done
