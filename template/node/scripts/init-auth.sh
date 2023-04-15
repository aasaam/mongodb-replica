#!/bin/bash

set -e

TMPFILE=$(mktemp /tmp/create-db.XXXXXX.js)

echo "
disableTelemetry();

use admin;
disableTelemetry();
db.createUser({
  user: 'root',
  pwd: '__ROOT_PASSWORD__',
  roles: [{ role: 'root', db: 'admin' }],
});
db.auth('root', '__ROOT_PASSWORD__');
db.createUser({
  user: 'root_readonly',
  pwd: '__ROOT_READONLY_PASSWORD__',
  roles: [
    { role: 'readAnyDatabase', db: 'admin' },
    { role: 'clusterMonitor', db: 'admin' },
  ],
});

quit();
" > $TMPFILE

cat $TMPFILE | mongosh --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem

rm -rf $TMPFILE
