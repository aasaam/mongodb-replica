#!/bin/bash

DB_FULL_BACKUP_LIST=$1
DB_COLLECTION_DAILY_BACKUP=$2
MIN_LOAD_INPUT=$3

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

IFS=', ' read -r -a DB_LIST <<< "$DB_FULL_BACKUP_LIST"
for DBNAME in "${DB_LIST[@]}"
do
  docker exec __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.db.create.sh $DBNAME
done

IFS=', ' read -r -a DB_COL_LIST <<< "$DB_COLLECTION_DAILY_BACKUP"
for DB_COL_NAME in "${DB_COL_LIST[@]}"
do
  IFS='. ' read -r -a DB_COL_PART <<< "$DB_COL_NAME"

  DB_NAME="${DB_COL_PART[0]}"
  COL_NAME="${DB_COL_PART[1]}"

  if [ -z "${DB_NAME}" ]; then
    echo "database name not present"
    continue
  fi

  if [ -z "${COL_NAME}" ]; then
    echo "collection name not present"
    continue
  fi

  docker exec __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.collection.create.daily.sh $DB_NAME $COL_NAME 0
  docker exec __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.collection.create.daily.sh $DB_NAME $COL_NAME 1

done

# garbage collector
docker exec __NAMESPACE__-mongo-__NODE_ID__ /scripts/gc.sh
