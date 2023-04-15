#!/bin/bash

docker exec -it __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.db.restore.sh $1 $2
