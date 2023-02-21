#!/bin/bash

set -e

APPNAME=$1
SUFFIX=$(tr -dc a-z0-9 </dev/urandom | head -c 10 ; echo '')
APPPREFIX=$APPNAME-$SUFFIX
USERNAME_ADMIN="ua-${APPPREFIX}"
USERNAME_READONLY="ur-${APPPREFIX}"
DATABASE="db-${APPPREFIX}"
ADMIN_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32 ; echo '')
READONLY_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32 ; echo '')

if [[ "$APPNAME" =~ ^[a-z][a-z0-9]{2,15}$ ]]; then
  echo "your application prefix is $APPPREFIX"
  echo "copy these for later use it's not shown again:"
  echo "database:       $DATABASE"
  echo "admin user:     $USERNAME_ADMIN"
  echo "readonly user:  $USERNAME_READONLY"
  echo "admin pass:     $ADMIN_PASSWORD"
  echo "readonly pass:  $READONLY_PASSWORD"
  echo "connection string will be:"
  echo ""
  echo "mongodb://$USERNAME_ADMIN:$ADMIN_PASSWORD@__NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__,__NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__,__NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__/$DATABASE?replicaSet=__NAMESPACE__"
  echo ""
  read -p "Confirm? [y] " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "creating users and database..."
  else
    echo "skipped"
    exit 0
  fi
else
  echo "invalid application name must be ^[a-z][a-z0-9]{3,15}$"
  exit 1
fi

TMPFILE=$(mktemp /tmp/create-db.XXXXXX.js)

echo "
use $DATABASE;
disableTelemetry();
db.setProfilingLevel(1, { slowms: 1000, sampleRate: 0.33 })
db.createUser({
  user: '$USERNAME_ADMIN',
  pwd: '$ADMIN_PASSWORD',
  roles: [
    { role: 'dbOwner', db: '$DATABASE' },
  ],
});
db.createUser({
  user: '$USERNAME_READONLY',
  pwd: '$READONLY_PASSWORD',
  roles: [
    { role: 'read', db: '$DATABASE' },
  ],
});
db.init_tmp_collection_$SUFFIX.insert({_id: new ObjectId(\"000000000000000000000000\")});
quit();
" > $TMPFILE

cat $TMPFILE | mongosh --username root --password __ROOT_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem

rm -rf $TMPFILE
