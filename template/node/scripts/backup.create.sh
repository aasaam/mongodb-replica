#!/bin/bash

set -e

DBNAME=$1
MODE=$2

if [ -z "${DBNAME}" ]; then
  echo "database name not present"
  exit 1
fi

DATE_PATTERN=$(date +%F)
if [ "$MODE" == "now" ]; then
  DATE_PATTERN=$(date +%Y-%m-%d.%s.%N)
fi

BACKUP_FILE="/backup/mongo-__NAMESPACE__-$DBNAME-full-$DATE_PATTERN.tgz"

if [ ! -f $BACKUP_FILE ]; then
  echo "$(date +"%Y-%m-%dT%H:%M:%S%z")  INFRASTRUCTURE_BACKUP_OPRATION: mongo replication backup $BACKUP_FILE created for database $DBNAME; compressed size is $BACKUP_FILE_SIZE"

  START_TIME=$(date +%s)
  # create backup
  mongodump --db=$DBNAME --authenticationDatabase admin --username root --password __ROOT_PASSWORD__ --uri="mongodb://__HOSTS_PORTS__/?tls=true&tlsCertificateKeyFile=/cert/client-combined.pem&tlsCAFile=/cert/ca.pem&replicaSet=__NAMESPACE__" --gzip --archive=$BACKUP_FILE
  END_TIME=$(date +%s)
  PROCESS_TIME=$(($END_TIME-$START_TIME))

  # log
  BACKUP_FILE_SIZE=$(ls -lh $BACKUP_FILE | awk '{print $5}')
  echo "$(date +"%Y-%m-%dT%H:%M:%S%z")  INFRASTRUCTURE_BACKUP_OPRATION: mongo replication backup $BACKUP_FILE created in $PROCESS_TIME seconds for database $DBNAME; compressed size is $BACKUP_FILE_SIZE"
else
  # log
  echo "$(date +"%Y-%m-%dT%H:%M:%S%z")  INFRASTRUCTURE_BACKUP_OPRATION: mongo replication backup $BACKUP_FILE exist for database $DBNAME; skipped"
fi
