#!/bin/bash

set -e

DBNAME=$1
COLNAME=$2
FILE_NAME=$3

if [ -z "${DBNAME}" ]; then
  echo "database name not present"
  exit 1
fi

if [ -z "${COLNAME}" ]; then
  echo "collection name not present"
  exit 1
fi

BACKUP_FILE="/backup/$FILE_NAME"

if [ ! -f $BACKUP_FILE ]; then
  echo "backup file not exist ($FILE_NAME)"
  echo "current backup files list:"
  ls -lah /backup/
  exit 1
fi

echo "make sure your application is in readonly, down or ready for restore(for data integrity)"
read -p "is application ready ? [y] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "application is ready for restore data..."
else
  echo "skipped"
  exit 0
fi

echo "selected database:    $DBNAME"
echo "selected collection:  $COLNAME"
read -p "are you sure for restore data, latest confirmation? [y] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "start restoring..."
else
  echo "skipped"
  exit 0
fi

TMPPATH=$(mktemp -d /tmp/colExp-XXXXXX)

cp -rf $BACKUP_FILE $TMPPATH/
cd $TMPPATH
tar xf $FILE_NAME
JSON_PATH=$(realpath -s *.json)

if [ ! -f $JSON_PATH ]; then
  echo "backup json file not found:"
  ls -lah $BACKUP_FILE
  ls -lah $TMPPATH/
  exit 1
fi

mongoimport --username root --password __ROOT_PASSWORD__ \
  --ssl --sslCAFile /cert/ca.pem --sslPEMKeyFile /cert/client-combined.pem \
  --uri="mongodb://root:__ROOT_PASSWORD__@__HOSTS_PORTS__/$DBNAME?authSource=admin&tls=true&tlsCertificateKeyFile=/cert/client-combined.pem&tlsCAFile=/cert/ca.pem&replicaSet=__NAMESPACE__" \
  --db $DBNAME --collection $COLNAME --file $JSON_PATH

rm -rf $TMPPATH
