#!/bin/bash

set -e

PROJECT_PATH=$(realpath .)

__NAMESPACE__=$1
__DOMAIN__=$2

if [ ! -f ./cfssl ]; then
  echo "cfssl not exist try to download"
  wget -O /tmp/cfssl 'https://github.com/cloudflare/cfssl/releases/download/v1.6.3/cfssl_1.6.3_linux_amd64'
  wget -O /tmp/cfssljson 'https://github.com/cloudflare/cfssl/releases/download/v1.6.3/cfssljson_1.6.3_linux_amd64'
  mv /tmp/cfssl ./cfssl
  mv /tmp/cfssljson ./cfssljson
  chmod +x ./cfssl
  chmod +x ./cfssljson
fi

CFSSl=$(realpath ./cfssl)
CFSSLJSON=$(realpath ./cfssljson)
DHPARAM=$(realpath ./cert/dhparam.pem)

CERT_JSON_FILES=("csr-client.json" "csr-root.json" "csr-server.json")

DIST_PATH=$(realpath deploy/$__NAMESPACE__)

# skip if aleady exists
if [ -d "$DIST_PATH" ]; then
  echo "Namespace alreay exists... skipped"
  exit
fi

mkdir -p $DIST_PATH/cert
mkdir -p $DIST_PATH/client
cp -rf ./cert/*.json $DIST_PATH/cert/
cd $DIST_PATH/cert/

for JSON_FILE in ${CERT_JSON_FILES[@]}; do
  sed -i -e "s/__NAMESPACE__/$__NAMESPACE__/g" $JSON_FILE
  sed -i -e "s/__DOMAIN__/$__DOMAIN__/g" $JSON_FILE
done

# passwords
__ROOT_PASSWORD__=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 48 ; echo '')
__ROOT_READONLY_PASSWORD__=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 48 ; echo '')

# replica
__REPLICA_NAME__="$__NAMESPACE__"

# ports
INIT_PORT=27000
__NODE0_MONGO_PORT__=$(( $INIT_PORT + 0 ))
__NODE0_X_EXPORTER_PORT__=$(( $INIT_PORT + 5 ))

__NODE1_MONGO_PORT__=$(( $INIT_PORT + 10 ))
__NODE1_X_EXPORTER_PORT__=$(( $INIT_PORT + 15 ))

__NODE2_MONGO_PORT__=$(( $INIT_PORT + 20 ))
__NODE2_X_EXPORTER_PORT__=$(( $INIT_PORT + 25 ))

$CFSSl gencert -initca csr-root.json | $CFSSLJSON -bare ca
$CFSSl gencert -ca ca.pem -ca-key ca-key.pem -config ca-config.json -profile=server csr-server.json | $CFSSLJSON -bare server
$CFSSl gencert -ca ca.pem -ca-key ca-key.pem -config ca-config.json -profile=client csr-client.json | $CFSSLJSON -bare client
cat ca.pem server.pem > server-fullchain.pem
cat ca.pem client.pem > client-fullchain.pem
cat server-key.pem server.pem > server-combined.pem
cat client-key.pem client.pem > client-combined.pem
cp clien*.pem $DIST_PATH/client/
cp ca.pem $DIST_PATH/client/
cp $DHPARAM dhparam.pem

cd $PROJECT_PATH
NODE_LIST=("0" "1" "2")
for NODE_ID in ${NODE_LIST[@]}; do
  NODE_PATH=$DIST_PATH/node${NODE_ID}
  mkdir -p $NODE_PATH
  cp -rf $PROJECT_PATH/template/node/* $NODE_PATH/
  cp -rf $DIST_PATH/cert/serve*.pem $NODE_PATH/cert/
  cp -rf $DIST_PATH/cert/clien*.pem $NODE_PATH/cert/
  cp -rf $DIST_PATH/cert/ca.pem $NODE_PATH/cert/
  cp $DHPARAM $NODE_PATH/cert/dhparam.pem
  sudo chmod 444 $NODE_PATH/cert/*.pem
  sudo chmod 777 $NODE_PATH/*.sh
  sudo chmod 777 $NODE_PATH/scripts/*.sh

  if [ $NODE_ID == "0" ]; then
    __NODE_MONGO_PORT__=$__NODE0_MONGO_PORT__
    __NODE_X_EXPORTER_PORT__=$__NODE0_X_EXPORTER_PORT__

  elif [ $NODE_ID == "1" ]; then
    __NODE_MONGO_PORT__=$__NODE1_MONGO_PORT__
    __NODE_X_EXPORTER_PORT__=$__NODE1_X_EXPORTER_PORT__

  elif [ $NODE_ID == "2" ]; then
    __NODE_MONGO_PORT__=$__NODE2_MONGO_PORT__
    __NODE_X_EXPORTER_PORT__=$__NODE2_X_EXPORTER_PORT__

  fi

  # not init node
  if [ $NODE_ID != "0" ]; then
    rm -rf $NODE_PATH/ini*.sh
    rm -rf $NODE_PATH/scripts/ini*.sh
  fi

  echo "MongoReplicaShard $__NAMESPACE__" > $NODE_PATH/README.txt
  echo "root password:                    $__ROOT_PASSWORD__" >> $NODE_PATH/README.txt
  echo "root readonly password:           $__ROOT_READONLY_PASSWORD__" >> $NODE_PATH/README.txt

  echo "" >> $NODE_PATH/README.txt
  echo "Exporter:" >> $NODE_PATH/README.txt
  echo "http://127.0.0.1:$__NODE_X_EXPORTER_PORT__/metrics" >> $NODE_PATH/README.txt

  echo "" >> $NODE_PATH/README.txt
  echo "DNS:" >> $NODE_PATH/README.txt
  echo "$__NAMESPACE__-mongo-0.$__DOMAIN__" >> $NODE_PATH/README.txt
  echo "$__NAMESPACE__-mongo-1.$__DOMAIN__" >> $NODE_PATH/README.txt
  echo "$__NAMESPACE__-mongo-2.$__DOMAIN__" >> $NODE_PATH/README.txt
  echo "$__REPLICA_NAME__" >> $NODE_PATH/README.txt

  echo "" >> $NODE_PATH/README.txt
  cat $NODE_PATH/HELP >> $NODE_PATH/README.txt
  rm -rf $NODE_PATH/HELP

  for FILE_TO_REPLACE in $(find $NODE_PATH -type f -regex ".*\.\(sh\|js\|yml\|conf\)"); do
    sed -i -e "s/__NAMESPACE__/$__NAMESPACE__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE_ID__/$NODE_ID/g" $FILE_TO_REPLACE
    sed -i -e "s/__DOMAIN__/$__DOMAIN__/g" $FILE_TO_REPLACE

    sed -i -e "s/__ROOT_PASSWORD__/$__ROOT_PASSWORD__/g" $FILE_TO_REPLACE
    sed -i -e "s/__ROOT_READONLY_PASSWORD__/$__ROOT_READONLY_PASSWORD__/g" $FILE_TO_REPLACE

    sed -i -e "s/__NODE_MONGO_PORT__/$__NODE_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE_X_EXPORTER_PORT__/$__NODE_X_EXPORTER_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__REPLICA_NAME__/$__REPLICA_NAME__/g" $FILE_TO_REPLACE

    sed -i -e "s/__NODE0_MONGO_PORT__/$__NODE0_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE1_MONGO_PORT__/$__NODE1_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE2_MONGO_PORT__/$__NODE2_MONGO_PORT__/g" $FILE_TO_REPLACE
  done
done
