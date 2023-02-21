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
  # prevent paraller backups
  echo '1' > $BACKUP_FILE
  sleep 5
  sleep $((RANDOM % 10))

  # create backup
  mongodump --db=$DBNAME --authenticationDatabase admin --username root --password __ROOT_PASSWORD__ --uri="mongodb://__NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__,__NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__,__NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__/?tls=true&tlsCertificateKeyFile=/cert/client-combined.pem&tlsCAFile=/cert/ca.pem&replicaSet=__NAMESPACE__&readPreference=secondary" --gzip --archive=$BACKUP_FILE

  # log
  BACKUP_FILE_SIZE=$(ls -lh $BACKUP_FILE | awk '{print $5}')
  echo "mongo replication backup $BACKUP_FILE created for database $DBNAME; compressed size is $BACKUP_FILE_SIZE"
else
  # log
  echo "mongo replication backup $BACKUP_FILE exist for database $DBNAME; skipped"
fi
