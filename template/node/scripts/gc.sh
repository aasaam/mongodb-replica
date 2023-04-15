#!/bin/bash

find /tmp -type f -name '*.json'    -mtime +3 -delete
find /tmp -type f -name '*.tgz'     -mtime +3 -delete

find /backup -type f -name 'mongo-replication.__NAMESPACE__.*'  -mtime +15 -delete
