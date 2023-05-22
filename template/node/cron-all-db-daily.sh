#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

MIN_LOAD_INPUT=$1

MAX_CPU=$(grep -c ^processor /proc/cpuinfo)

MIN_LOAD="2,4,6"
if [[ $MIN_LOAD_INPUT != "" ]]; then
  MIN_LOAD=$MIN_LOAD_INPUT
fi

IFS=', ' read -r -a MAX_LOAD_PARAMS <<< "$MIN_LOAD"

MAX_LOAD01="${MAX_LOAD_PARAMS[0]}"
MAX_LOAD05="${MAX_LOAD_PARAMS[1]}"
MAX_LOAD15="${MAX_LOAD_PARAMS[2]}"

if [[ "${#MAX_LOAD_PARAMS[@]}" != "3" ]]; then
  echo "invalid load parameters"
  exit 1
fi

for LOAD_NUM in "${MAX_LOAD_PARAMS[@]}"
do
  if [[ $LOAD_NUM -lt 0 ]]; then
    echo "invalid load number $LOAD_NUM"
    exit 1
  elif [[ $LOAD_NUM -gt $MAX_CPU ]]; then
    echo "invalid load number $LOAD_NUM"
    exit 1
  fi
done

LOAD_CURRENT=$(cat /proc/loadavg)
LOAD_01=$(echo $LOAD_CURRENT | awk '{ print $1; }')
LOAD_05=$(echo $LOAD_CURRENT | awk '{ print $2; }')
LOAD_15=$(echo $LOAD_CURRENT | awk '{ print $3; }')

LOAD_01=$(printf "%.0f\n" "$LOAD_01")
LOAD_05=$(printf "%.0f\n" "$LOAD_05")
LOAD_15=$(printf "%.0f\n" "$LOAD_15")

if [[ $LOAD_01 -gt $MAX_LOAD01 ]] || [[ $LOAD_05 -gt $MAX_LOAD05 ]] || [[ $LOAD_15 -gt $MAX_LOAD15 ]]; then
  echo "system load is high; current load $LOAD_CURRENT; max set for upload $MIN_LOAD; skipped"
  exit 0
fi

DB_LIST=$SCRIPT_DIR/cron-production-db-list.txt

$SCRIPT_DIR/db.list.sh > $DB_LIST

while read DB_NAME; do
  if [ -z "$DB_NAME" ]; then
    continue
  fi
  $SCRIPT_DIR/backup.db.create.sh $DB_NAME
done <$DB_LIST

$SCRIPT_DIR/scripts/gc.sh
