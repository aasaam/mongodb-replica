#!/bin/bash

set -e

NOCOLOR='\033[0m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'

MODE=$1

if [ "$MODE" == "root" ]; then
  echo -e "${RED}CAUTION: You're ${GREEN}root${RED} via read and write access${NOCOLOR}"
  docker exec -it __NAMESPACE__-mongo-__NODE_ID__ mongosh --username root --password __ROOT_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem
else
  echo -e "${YELLOW}You're ${GREEN}root_readonly${YELLOW} via read access${NOCOLOR}"
  docker exec -it __NAMESPACE__-mongo-__NODE_ID__ mongosh --username root_readonly --password __ROOT_READONLY_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem
fi
