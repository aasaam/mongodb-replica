#!/bin/bash

docker exec -it __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.collection.restore.sh $1 $2 $3
