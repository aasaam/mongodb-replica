#!/bin/bash

set -e

NOCOLOR='\033[0m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'

MODE=$1

if [ "$MODE" == "replica" ]; then
  docker exec __NAMESPACE__-mongo-__NODE_ID__ mongosh --quiet --eval "EJSON.stringify(rs.status())" --username root --password __ROOT_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem
else
  docker exec __NAMESPACE__-mongo-__NODE_ID__ mongosh --quiet --eval "EJSON.stringify(db.runCommand({ serverStatus: 1}))" --username root --password __ROOT_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem
fi
