#!/bin/bash

set -e

export TZ=UTC

DBNAME=$1
COLLECTIONS=$2
OFFSET=$3

if [ -z "${DBNAME}" ]; then
  echo "database name not present"
  exit 1
fi

if [ -z "${COLLECTIONS}" ]; then
  echo "collections name not present, using comma separted"
  exit 1
fi

if [[ $OFFSET -lt 0 ]]; then
  echo "offset must >= 0 (now) and <= 36600 (about 100 year ago)"
  exit 1
elif [[ $OFFSET -gt 36600 ]]; then
  echo "offset must >= 0 (now) and <= 36600 (about 100 year ago)"
  exit 1
fi

if [[ "$OFFSET" -eq "0" ]]; then
  DATE_STRING_S=$(date +"%Y-%m-%dT00:00:00.000Z")
  DATE_STRING_E=$(date +"%Y-%m-%dT23:59:59.999Z")
else
  DATE_STRING_S=$(date --date="$OFFSET days ago" +"%Y-%m-%dT00:00:00.000Z")
  DATE_STRING_E=$(date --date="$OFFSET days ago" +"%Y-%m-%dT23:59:59.999Z")
fi

DATE_STRING_S=$(date -d "$DATE_STRING_S" +"%s")
DATE_STRING_E=$(date -d "$DATE_STRING_E" +"%s")

DATE_NAME=$(date -d @$DATE_STRING_S +%Y-%m-%d)
if [[ "$OFFSET" -eq "0" ]]; then
  RANDOM_SUFFIX=$(openssl rand -hex 32 | head -c 8)
  DATE_PATTERN=$(date +%Y-%m-%d-%H-%M-%S-%N)
  DATE_NAME="$DATE_NAME.$DATE_PATTERN-$RANDOM_SUFFIX"
fi

FILTER_S="000000000000000000000000"
FILTER_E="ffffffffffffffffffffffff"

MONGDB_OBJECTID_S=$(printf "%x" "$DATE_STRING_S")
MONGDB_OBJECTID_E=$(printf "%x" "$DATE_STRING_E")

MONGDB_OBJECTID_S=$(printf '%s' "$MONGDB_OBJECTID_S${FILTER_S:${#MONGDB_OBJECTID_S}}")
MONGDB_OBJECTID_E=$(printf '%s' "$MONGDB_OBJECTID_E${FILTER_E:${#MONGDB_OBJECTID_E}}")

MONGOEXPORT_QUERY=$(printf '{"_id":{"$gte":{"$oid":"%s"},"$lte":{"$oid":"%s"}}}' "$MONGDB_OBJECTID_S" "$MONGDB_OBJECTID_E")
TMPFILE=$(mktemp /tmp/col.$DBNAME.XXXXXX.json)
echo $MONGOEXPORT_QUERY > $TMPFILE

for COL in ${COLLECTIONS//,/ }
do
  JSON_FILE_NAME=col.$DBNAME.$COL.$DATE_NAME.json
  TAR_FILE_NAME=mongo-replication.__NAMESPACE__.$JSON_FILE_NAME.tgz

  JSON_PATH=/tmp/$JSON_FILE_NAME
  TAR_PATH=/tmp/$TAR_FILE_NAME

  BACKUP_FILE=/backup/$TAR_FILE_NAME

  if [[ -f "$BACKUP_FILE" ]]; then
    echo "$(date +"%Y-%m-%dT%H:%M:%S%z")  INFRASTRUCTURE_BACKUP_OPERATION:($DBNAME.$COL) mongo replication backup collection $TAR_FILE_NAME exists; skipped"
    continue
  fi

  START_CREATE=$(date +%s.%N)

  rm -rf $JSON_PATH
  rm -rf $TAR_PATH

  mongoexport --username root --password __ROOT_PASSWORD__ \
    --ssl --sslCAFile /cert/ca.pem --sslPEMKeyFile /cert/client-combined.pem \
    --uri="mongodb://root:__ROOT_PASSWORD__@__HOSTS_PORTS__/$DBNAME?authSource=admin&tls=true&tlsCertificateKeyFile=/cert/client-combined.pem&tlsCAFile=/cert/ca.pem&replicaSet=__NAMESPACE__" \
    --db $DBNAME --collection $COL --queryFile $TMPFILE --sort "{_id:1}" --out $JSON_PATH

  cd /tmp
  tar -czf $TAR_FILE_NAME $JSON_FILE_NAME

  rm -rf $JSON_PATH

  PROCESS_TIME=$(date +%s.%N --date="$START_CREATE seconds ago")
  BACKUP_FILE_SIZE=$(ls -lh $TAR_FILE_NAME | awk '{print $5}')

  mv $TAR_PATH $BACKUP_FILE

  echo "$(date +"%Y-%m-%dT%H:%M:%S%z")  INFRASTRUCTURE_BACKUP_OPERATION:($DBNAME.$COL) mongo replication backup collection $DBNAME.$COL $TAR_FILE_NAME created in $PROCESS_TIME seconds;"

done

rm -rf $TMPFILE
