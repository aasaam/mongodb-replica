#!/bin/bash

docker exec __NAMESPACE__-mongo-__NODE_ID__ mongosh --quiet --username root --password __ROOT_PASSWORD__ --port __NODE_MONGO_PORT__ --host 127.0.0.1 --tls --tlsCAFile /cert/ca.pem --tlsCertificateKeyFile /cert/client-combined.pem --eval "JSON.stringify(db.adminCommand({ listDatabases:1 }).databases)" | jq -r '.[].name' | grep -E '^db-.*' | sort
