#!/bin/bash
# backup_instances_to_ami.sh
# This script is used to backup (windows) instances to launchable AMIs

INSTANCES=( instancename1:us-east-1 instancename2:eu-west-1 )
DATE="$(date +%Y%m%d)"
AMI_RETENTION=4 # number of backups to keep
SCRIPTNAME="$(basename "$0")"
HOSTNAME="$(hostname)"
ZABBIX_ITEM="backup_to_ami.status"

set -o pipefail

log() {
  echo "$(date '+%Y-%m-%dT%H:%M:%S')" "$@"
}

exit_fail() {
  log "$@"
  log "Emergency exit"
  log "Sending result to Zabbix"
  /usr/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -k "$ZABBIX_ITEM" -o 1
  exit 1
}

exit_success() {
  log "$@"
  log "Sending result to Zabbix"
  /usr/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -k "$ZABBIX_ITEM" -o 0
  exit 0
}

log "Starting $SCRIPTNAME on $HOSTNAME"

for instance_spec in "${INSTANCES[@]}"; do

  IFS=': ' read -r instance_name instance_region <<< "$instance_spec"
  if [[ -z "$instance_name" || -z "$instance_region" ]]; then
    exit_fail "Broken instance specification, check the script"
  fi

  log "-----"
  log "Backing up $instance_name in $instance_region"
  if ! instance_id="$(aws ec2 describe-instances --output json --region="$instance_region" --filters "Name=tag:Name,Values=$instance_name" | grep "InstanceId" | cut -d\" -f4)"; then
    exit_fail "Error getting instance ID. No such instance?"
  fi

  log "Creating AMI of $instance_id"
  if ! aws ec2 create-image --output json --region="$instance_region" --instance-id "$instance_id" --name "${instance_name}-ami-${DATE}" --no-reboot --description "Automatic backup by $SCRIPTNAME on $HOSTNAME"; then
    exit_fail "Error creating AMI for $instance_id"
  fi

  log "Cleaning up older AMIs (AMI_RETENTION = $AMI_RETENTION)"
  if ! ami_list="$(aws ec2 describe-images --output json --region="$instance_region" --owners self --filters "Name=name,Values=${instance_name}-ami-*" | grep '\"Name\":' | cut -d\" -f4 | sort -r)"; then
    exit_fail "Error getting AMI list"
  fi
  log "Current AMI list: $ami_list"

  ami_list_to_delete="$(echo "$ami_list" | tail -n+$((AMI_RETENTION + 1)) )"

  if [ ! -z "$ami_list_to_delete" ]; then
    while read -r ami_to_delete; do
      if ! snapshot_list_to_delete="$(aws ec2 describe-images --output json --region="$instance_region" --owners self --filters "Name=name,Values=$ami_to_delete" | grep '\"SnapshotId\":' | cut -d\" -f4)"; then
        exit_fail "Error getting a list of snapshot IDs for $ami_to_delete"
      fi

      if ! ami_id_to_delete="$(aws ec2 describe-images --output json --region="$instance_region" --owners self --filters "Name=name,Values=$ami_to_delete" | grep '\"ImageId\":' | cut -d\" -f4)"; then
        exit_fail "Error getting AMI ID for $ami_to_delete"
      fi

      log "Deregistering $ami_to_delete ($ami_id_to_delete)"
      if ! aws ec2 deregister-image --output json --region="$instance_region" --image-id "$ami_id_to_delete"; then
        exit_fail "Error deregistering $ami_to_delete"
      fi

      while read -r snapshot_to_delete; do
        log "Deleting $snapshot_to_delete ($ami_id_to_delete)"
        if ! aws ec2 delete-snapshot --output json --region="$instance_region" --snapshot-id "$snapshot_to_delete"; then
          exit_fail "Error deleting snapshot $snapshot_to_delete"
        fi
      done <<< "$snapshot_list_to_delete"

    done <<< "$ami_list_to_delete"
  else
    log "No backups to delete"
  fi

done

exit_success "Finished successfully"

# the end
