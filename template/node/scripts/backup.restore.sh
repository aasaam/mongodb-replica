#!/bin/bash

set -e

DBNAME=$1
FILE_NAME=$2

if [ -z "${DBNAME}" ]; then
  echo "database name not present"
  exit 1
fi

BACKUP_FILE="/backup/$FILE_NAME"

if [ ! -f $BACKUP_FILE ]; then
  echo "backup file not exist ($FILE_NAME)"
  echo "current backup files list:"
  ls -lah /backup/
  exit 1
fi

read -p "old database will be drop and backups will be replaces? [y] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "start restoring..."
else
  echo "skipped"
  exit 0
fi

echo "drop old database..."
mongosh --eval "use $DBNAME; db.dropDatabase()" --username root --password __ROOT_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem
sleep 5

echo "restoring..."
mongorestore --drop --db=$DBNAME --authenticationDatabase admin --username root --password __ROOT_PASSWORD__ --uri="mongodb://__NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__,__NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__,__NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__/?tls=true&tlsCertificateKeyFile=/cert/client-combined.pem&tlsCAFile=/cert/ca.pem&replicaSet=__NAMESPACE__" --gzip --archive=$BACKUP_FILE

