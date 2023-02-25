#!/bin/bash

set -e

TMPFILE=$(mktemp /tmp/create-db.XXXXXX.js)

echo "
disableTelemetry();

var rsConfig = {
  _id: '__REPLICA_NAME__',
  version: 1,
  members: [
    {
      _id: 0,
      host: '__NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__',
      priority: 3,
    },
    {
      _id: 1,
      host: '__NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__',
      priority: 2,
    },
    {
      _id: 2,
      host: '__NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__',
      priority: 2,
    },
    {
      _id: 3,
      host: '__NAMESPACE__-mongo-3.__DOMAIN__:__NODE3_MONGO_PORT__',
      priority: 2,
    },
    {
      _id: 4,
      host: '__NAMESPACE__-mongo-4.__DOMAIN__:__NODE4_MONGO_PORT__',
      priority: 1,
    },
    {
      _id: 5,
      host: '__NAMESPACE__-mongo-5.__DOMAIN__:__NODE5_MONGO_PORT__',
      priority: 1,
    },
    {
      _id: 6,
      host: '__NAMESPACE__-mongo-6.__DOMAIN__:__NODE6_MONGO_PORT__',
      priority: 0,
      hidden : true,
      secondaryDelaySecs: 10,
    },
  ],
};

rs.initiate(rsConfig, { force: true });
" > $TMPFILE

cat $TMPFILE | mongosh --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/server-combined.pem

rm -rf $TMPFILE
echo ""
