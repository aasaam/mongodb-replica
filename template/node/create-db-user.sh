#!/bin/bash

docker exec -u root -it __NAMESPACE__-mongo-__NODE_ID__ /scripts/create-db-user.sh $1
