#!/bin/bash

set -e

NOCOLOR='\033[0m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'

waitport() {
  while ! nc -z $1 $2 ; do sleep 1 ; done
}

echo -e "${PURPLE}waiting node0 __NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__${NOCOLOR}"
waitport __NAMESPACE__-mongo-0.__DOMAIN__ __NODE0_MONGO_PORT__
echo -e "${GREEN}__NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__ is up${NOCOLOR}"

echo -e "${PURPLE}waiting node1 __NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__${NOCOLOR}"
waitport __NAMESPACE__-mongo-1.__DOMAIN__ __NODE1_MONGO_PORT__
echo -e "${GREEN}__NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__ is up${NOCOLOR}"

echo -e "${PURPLE}waiting node2 __NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__${NOCOLOR}"
waitport __NAMESPACE__-mongo-2.__DOMAIN__ __NODE2_MONGO_PORT__
echo -e "${GREEN}__NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__ is up${NOCOLOR}"

echo -e "${PURPLE}initialize replication${NOCOLOR}"
docker exec -u root __NAMESPACE__-mongo-__NODE_ID__ /scripts/init-replica.sh

echo -e "${YELLOW}replication successfully added. please wait 30 seconds to replica fully started...${NOCOLOR}"

for i in {1..30}; do
  echo -ne "\r${i}"
  sleep 1
done
echo ""

echo -e "${GREEN}run './init-auth.sh' for enable auth${NOCOLOR}"

sudo rm -rf ./scripts/init-replica.sh
sudo mv init-replica.sh ./tmp/init-replica.sh.backup
sudo chmod 444 ./tmp/init-replica.sh.backup
