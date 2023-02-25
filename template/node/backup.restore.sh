#!/bin/bash

docker exec -it __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.restore.sh $1 $2
