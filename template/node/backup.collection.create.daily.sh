#!/bin/bash

docker exec __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.collection.create.daily.sh $1 $2 $3
