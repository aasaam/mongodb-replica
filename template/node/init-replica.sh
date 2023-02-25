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

wait_all() {
  echo -e "${PURPLE}waiting node0 __NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__${NOCOLOR}"  # 3NODEREPLICA:N0
  waitport __NAMESPACE__-mongo-0.__DOMAIN__ __NODE0_MONGO_PORT__                                    # 3NODEREPLICA:N0
  echo -e "${GREEN}__NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__ is up${NOCOLOR}"           # 3NODEREPLICA:N0
  echo -e "${PURPLE}waiting node1 __NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__${NOCOLOR}"  # 3NODEREPLICA:N1
  waitport __NAMESPACE__-mongo-1.__DOMAIN__ __NODE1_MONGO_PORT__                                    # 3NODEREPLICA:N1
  echo -e "${GREEN}__NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__ is up${NOCOLOR}"           # 3NODEREPLICA:N1
  echo -e "${PURPLE}waiting node2 __NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__${NOCOLOR}"  # 3NODEREPLICA:N2
  waitport __NAMESPACE__-mongo-2.__DOMAIN__ __NODE2_MONGO_PORT__                                    # 3NODEREPLICA:N2
  echo -e "${GREEN}__NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__ is up${NOCOLOR}"           # 3NODEREPLICA:N2

  echo -e "${PURPLE}waiting node0 __NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__${NOCOLOR}"  # 5NODEREPLICA:N0
  waitport __NAMESPACE__-mongo-0.__DOMAIN__ __NODE0_MONGO_PORT__                                    # 5NODEREPLICA:N0
  echo -e "${GREEN}__NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__ is up${NOCOLOR}"           # 5NODEREPLICA:N0
  echo -e "${PURPLE}waiting node1 __NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__${NOCOLOR}"  # 5NODEREPLICA:N1
  waitport __NAMESPACE__-mongo-1.__DOMAIN__ __NODE1_MONGO_PORT__                                    # 5NODEREPLICA:N1
  echo -e "${GREEN}__NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__ is up${NOCOLOR}"           # 5NODEREPLICA:N1
  echo -e "${PURPLE}waiting node2 __NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__${NOCOLOR}"  # 5NODEREPLICA:N2
  waitport __NAMESPACE__-mongo-2.__DOMAIN__ __NODE2_MONGO_PORT__                                    # 5NODEREPLICA:N2
  echo -e "${GREEN}__NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__ is up${NOCOLOR}"           # 5NODEREPLICA:N2
  echo -e "${PURPLE}waiting node3 __NAMESPACE__-mongo-3.__DOMAIN__:__NODE3_MONGO_PORT__${NOCOLOR}"  # 5NODEREPLICA:N3
  waitport __NAMESPACE__-mongo-3.__DOMAIN__ __NODE3_MONGO_PORT__                                    # 5NODEREPLICA:N3
  echo -e "${GREEN}__NAMESPACE__-mongo-3.__DOMAIN__:__NODE3_MONGO_PORT__ is up${NOCOLOR}"           # 5NODEREPLICA:N3
  echo -e "${PURPLE}waiting node4 __NAMESPACE__-mongo-4.__DOMAIN__:__NODE4_MONGO_PORT__${NOCOLOR}"  # 5NODEREPLICA:N4
  waitport __NAMESPACE__-mongo-4.__DOMAIN__ __NODE4_MONGO_PORT__                                    # 5NODEREPLICA:N4
  echo -e "${GREEN}__NAMESPACE__-mongo-4.__DOMAIN__:__NODE4_MONGO_PORT__ is up${NOCOLOR}"           # 5NODEREPLICA:N4

  echo -e "${PURPLE}waiting node0 __NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__${NOCOLOR}"  # 7NODEREPLICA:N0
  waitport __NAMESPACE__-mongo-0.__DOMAIN__ __NODE0_MONGO_PORT__                                    # 7NODEREPLICA:N0
  echo -e "${GREEN}__NAMESPACE__-mongo-0.__DOMAIN__:__NODE0_MONGO_PORT__ is up${NOCOLOR}"           # 7NODEREPLICA:N0
  echo -e "${PURPLE}waiting node1 __NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__${NOCOLOR}"  # 7NODEREPLICA:N1
  waitport __NAMESPACE__-mongo-1.__DOMAIN__ __NODE1_MONGO_PORT__                                    # 7NODEREPLICA:N1
  echo -e "${GREEN}__NAMESPACE__-mongo-1.__DOMAIN__:__NODE1_MONGO_PORT__ is up${NOCOLOR}"           # 7NODEREPLICA:N1
  echo -e "${PURPLE}waiting node2 __NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__${NOCOLOR}"  # 7NODEREPLICA:N2
  waitport __NAMESPACE__-mongo-2.__DOMAIN__ __NODE2_MONGO_PORT__                                    # 7NODEREPLICA:N2
  echo -e "${GREEN}__NAMESPACE__-mongo-2.__DOMAIN__:__NODE2_MONGO_PORT__ is up${NOCOLOR}"           # 7NODEREPLICA:N2
  echo -e "${PURPLE}waiting node3 __NAMESPACE__-mongo-3.__DOMAIN__:__NODE3_MONGO_PORT__${NOCOLOR}"  # 7NODEREPLICA:N3
  waitport __NAMESPACE__-mongo-3.__DOMAIN__ __NODE3_MONGO_PORT__                                    # 7NODEREPLICA:N3
  echo -e "${GREEN}__NAMESPACE__-mongo-3.__DOMAIN__:__NODE3_MONGO_PORT__ is up${NOCOLOR}"           # 7NODEREPLICA:N3
  echo -e "${PURPLE}waiting node4 __NAMESPACE__-mongo-4.__DOMAIN__:__NODE4_MONGO_PORT__${NOCOLOR}"  # 7NODEREPLICA:N4
  waitport __NAMESPACE__-mongo-4.__DOMAIN__ __NODE4_MONGO_PORT__                                    # 7NODEREPLICA:N4
  echo -e "${GREEN}__NAMESPACE__-mongo-4.__DOMAIN__:__NODE4_MONGO_PORT__ is up${NOCOLOR}"           # 7NODEREPLICA:N4
  echo -e "${PURPLE}waiting node5 __NAMESPACE__-mongo-5.__DOMAIN__:__NODE5_MONGO_PORT__${NOCOLOR}"  # 7NODEREPLICA:N5
  waitport __NAMESPACE__-mongo-5.__DOMAIN__ __NODE5_MONGO_PORT__                                    # 7NODEREPLICA:N5
  echo -e "${GREEN}__NAMESPACE__-mongo-5.__DOMAIN__:__NODE5_MONGO_PORT__ is up${NOCOLOR}"           # 7NODEREPLICA:N5
  echo -e "${PURPLE}waiting node6 __NAMESPACE__-mongo-6.__DOMAIN__:__NODE6_MONGO_PORT__${NOCOLOR}"  # 7NODEREPLICA:N6
  waitport __NAMESPACE__-mongo-6.__DOMAIN__ __NODE6_MONGO_PORT__                                    # 7NODEREPLICA:N6
  echo -e "${GREEN}__NAMESPACE__-mongo-6.__DOMAIN__:__NODE6_MONGO_PORT__ is up${NOCOLOR}"           # 7NODEREPLICA:N6
}

wait_all

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
