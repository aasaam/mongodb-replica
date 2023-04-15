#!/bin/bash

docker exec __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.db.create.sh $1 $2
