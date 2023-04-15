#!/bin/bash

set -e

export TZ=UTC

DBNAME=$1
MODE=$2

if [ -z "${DBNAME}" ]; then
  echo "database name not present"
  exit 1
fi

DATE_PATTERN=$(date +%F)
if [ "$MODE" == "now" ]; then
  RANDOM_SUFFIX=$(openssl rand -hex 32 | head -c 8)
  DATE_PATTERN=$(date +%Y-%m-%d-%H-%M-%S-%N)
  DATE_PATTERN=$DATE_PATTERN-$RANDOM_SUFFIX
fi

BACKUP_FILE="/backup/mongo-replication.__NAMESPACE__.db.$DBNAME.$DATE_PATTERN.tgz"

if [ ! -f $BACKUP_FILE ]; then
  echo "$(date +"%Y-%m-%dT%H:%M:%S%z")  INFRASTRUCTURE_BACKUP_OPERATION:($DBNAME) mongo replication backup db $BACKUP_FILE start creation..."

  START_CREATE=$(date +%s.%N)

  # create backup
  mongodump --db=$DBNAME --authenticationDatabase admin --username root --password __ROOT_PASSWORD__ --uri="mongodb://__HOSTS_PORTS__/?tls=true&tlsCertificateKeyFile=/cert/client-combined.pem&tlsCAFile=/cert/ca.pem&replicaSet=__NAMESPACE__" --gzip --archive=$BACKUP_FILE

  PROCESS_TIME=$(date +%s.%N --date="$START_CREATE seconds ago")

  # log
  BACKUP_FILE_SIZE=$(ls -lh $BACKUP_FILE | awk '{print $5}')

  echo "$(date +"%Y-%m-%dT%H:%M:%S%z")  INFRASTRUCTURE_BACKUP_OPERATION:($DBNAME) mongo replication backup db $BACKUP_FILE successfully created in $PROCESS_TIME seconds; compressed size is $BACKUP_FILE_SIZE"

else

  # log
  echo "$(date +"%Y-%m-%dT%H:%M:%S%z")  INFRASTRUCTURE_BACKUP_OPERATION:($DBNAME) mongo replication backup db $BACKUP_FILE exist; skipped"

fi
