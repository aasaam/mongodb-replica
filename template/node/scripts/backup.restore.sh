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

echo "make sure your application is in readonly or down, for data integrity"
read -p "is application down or read only ? [y] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "application confirm is down or readonly..."
else
  echo "skipped"
  exit 0
fi

read -p "old database will be drop and backups will be replaces, latest confirmation? [y] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "start restoring..."
else
  echo "skipped"
  exit 0
fi

echo "drop old database..."
mongosh --eval "use $DBNAME; db.dropDatabase()" --username root --password __ROOT_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem

echo "restoring..."
mongorestore --drop --db=$DBNAME --authenticationDatabase admin --username root --password __ROOT_PASSWORD__ --uri="mongodb://__HOSTS_PORTS__/?tls=true&tlsCertificateKeyFile=/cert/client-combined.pem&tlsCAFile=/cert/ca.pem&replicaSet=__NAMESPACE__" --gzip --archive=$BACKUP_FILE

