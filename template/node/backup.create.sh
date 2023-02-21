#!/bin/bash

docker exec -u root -it __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.create.sh $1 $2
