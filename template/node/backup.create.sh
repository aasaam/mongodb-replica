#!/bin/bash

docker exec __NAMESPACE__-mongo-__NODE_ID__ /scripts/backup.create.sh $1 $2
