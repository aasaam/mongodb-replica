#!/bin/bash

docker exec -it __NAMESPACE__-mongo-__NODE_ID__ /scripts/create-db-user.sh $1
