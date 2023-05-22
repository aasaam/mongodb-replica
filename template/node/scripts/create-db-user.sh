#!/bin/bash

set -e

APPPREFIX=$1
USERNAME_ADMIN="ua-${APPPREFIX}"
USERNAME_READONLY="ur-${APPPREFIX}"
DATABASE="db-${APPPREFIX}"
ADMIN_PASSWORD=$(openssl rand -base64 64 | tr -dc A-Za-z0-9 | head -c 48 ; echo '')
READONLY_PASSWORD=$(openssl rand -base64 64 | tr -dc A-Za-z0-9 | head -c 48 ; echo '')

if [[ "$APPPREFIX" =~ ^[a-z][a-z0-9\-]{2,29}$ ]]; then
  echo "your application prefix is $APPPREFIX"
  echo "copy these for later use it's not shown again:"
  echo "database:       $DATABASE"
  echo "admin user:     $USERNAME_ADMIN"
  echo "readonly user:  $USERNAME_READONLY"
  echo "admin pass:     $ADMIN_PASSWORD"
  echo "readonly pass:  $READONLY_PASSWORD"
  echo "connection string will be:"
  echo ""
  echo "mongodb://$USERNAME_ADMIN:$ADMIN_PASSWORD@__HOSTS_PORTS__/$DATABASE?replicaSet=__NAMESPACE__"
  echo ""
  echo "also you will need cert files(.pem) include in 'client-cert' for establish tls communication"
  echo ""
  read -p "Confirm? [y] " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "creating users and database..."
  else
    echo "skipped"
    exit 0
  fi
else
  echo "invalid application name must be ^[a-z][a-z0-9\-]{2,29}$"
  exit 1
fi

TMPFILE=$(mktemp /tmp/create-db.XXXXXX.js)

echo "
disableTelemetry();
use $DATABASE;
disableTelemetry();
db.setProfilingLevel(1, { slowms: 1000, sampleRate: 0.33 });
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
db.temporaryInitializeCollectionThatYouCanRemove.insert({_id: new ObjectId()});
" > $TMPFILE

cat $TMPFILE | mongosh --username root --password __ROOT_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem

rm -rf $TMPFILE
