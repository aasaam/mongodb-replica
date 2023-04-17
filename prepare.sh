#!/bin/bash

set -e

PROJECT_PATH=$(realpath .)

__NAMESPACE__=$1
__DOMAIN__=$2
__NODES__=$3
__INIT_PORT__=$4

if [ -z "$__NODES__" ]; then
  __NODES__=3
fi

if [ -z "$__INIT_PORT__" ]; then
  __INIT_PORT__=27000
fi

if [[ ! $__NODES__ =~ ^(3|5|7)$ ]]; then
  echo "invalid node numbers, supported is 3, 5 and 7"
  exit 1
fi
__NODES_NZ__=$__NODES__
((__NODES__-=1))

if [ "$__INIT_PORT__" -ge 48000 ] || [ "$__INIT_PORT__" -le 1300 ]; then
  echo "invalid port number, must be '>= 1300' and '<= 48000'"
  exit 1
fi

REQUIRE_PORTS=()
HOSTS_PORTS_TEMPLATE=()
for NODE_ID in $( seq 0 $__NODES__ )
do
  PORT_OFFSET=$(( $NODE_ID * 10))
  declare "__NODE${NODE_ID}_MONGO_PORT__"=$(( $__INIT_PORT__ + $PORT_OFFSET + 0 ))
  declare "__NODE${NODE_ID}_X_WEB_UI_PORT__"=$(( $__INIT_PORT__ + $PORT_OFFSET + 5 ))
  declare "__NODE${NODE_ID}_X_EXPORTER_PORT__"=$(( $__INIT_PORT__ + $PORT_OFFSET + 9 ))
  REQUIRE_PORTS+=("__NODE${NODE_ID}_MONGO_PORT__")
  REQUIRE_PORTS+=("__NODE${NODE_ID}_X_WEB_UI_PORT__")
  REQUIRE_PORTS+=("__NODE${NODE_ID}_X_EXPORTER_PORT__")
  HOSTS_PORTS_TEMPLATE+=("__NAMESPACE__-mongo-${NODE_ID}.__DOMAIN__:__NODE${NODE_ID}_MONGO_PORT__")
done
__HOSTS_PORTS__=$(IFS=, ; echo "${HOSTS_PORTS_TEMPLATE[*]}")


if [ ! -f ./cfssl ]; then
  echo "cfssl not exist try to download"
  wget -O /tmp/cfssl 'https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl_1.6.4_linux_amd64'
  wget -O /tmp/cfssljson 'https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssljson_1.6.4_linux_amd64'
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

CERT_WORK_DIR=$DIST_PATH/cert.tmp
CERT_DIR=$DIST_PATH/cert
mkdir -p $CERT_WORK_DIR
mkdir -p $CERT_DIR
cp -rf ./cert/*.json $CERT_WORK_DIR/
cd $CERT_WORK_DIR

for JSON_FILE in ${CERT_JSON_FILES[@]}; do
  sed -i -e "s/__NAMESPACE__/$__NAMESPACE__/g" $JSON_FILE
  sed -i -e "s/__DOMAIN__/$__DOMAIN__/g" $JSON_FILE
done

$CFSSl gencert -initca csr-root.json | $CFSSLJSON -bare ca

# server(node) certificates
for NODE_ID in $( seq 0 9 )
do
  rm -rf clien*.pem
  rm -rf server*.pem
  rm -rf *.csr
  # client cert
  $CFSSl gencert -ca ca.pem -ca-key ca-key.pem -config ca-config.json -profile=client csr-client.json | $CFSSLJSON -bare client
  # server cert
  $CFSSl gencert -ca ca.pem -ca-key ca-key.pem -config ca-config.json -profile=server csr-server.json | $CFSSLJSON -bare server

  OUT_DIR=$DIST_PATH/cert/node${NODE_ID}
  mkdir -p $OUT_DIR

  cat ca.pem client.pem > $OUT_DIR/client-fullchain.pem
  cat ca.pem server.pem > $OUT_DIR/server-fullchain.pem
  cat client-key.pem client.pem > $OUT_DIR/client-combined.pem
  cat server-key.pem server.pem > $OUT_DIR/server-combined.pem

  cp ca.pem $OUT_DIR/
  mv client-key.pem $OUT_DIR/
  mv client.pem $OUT_DIR/
  mv server-key.pem $OUT_DIR/
  mv server.pem $OUT_DIR/
  chmod 444 $OUT_DIR/*.pem
done

# client
$CFSSl gencert -ca ca.pem -ca-key ca-key.pem -config ca-config.json -profile=client csr-client.json | $CFSSLJSON -bare client
CLIENT_CERT_DIR=$DIST_PATH/cert/client
mkdir -p $CLIENT_CERT_DIR
cat ca.pem client.pem > $CLIENT_CERT_DIR/client-fullchain.pem
cat client-key.pem ca.pem client.pem > $CLIENT_CERT_DIR/client-combined-fullchain.pem
cat client-key.pem client.pem > $CLIENT_CERT_DIR/client-combined.pem
cp ca.pem $CLIENT_CERT_DIR/
mv client-key.pem $CLIENT_CERT_DIR/
mv client.pem $CLIENT_CERT_DIR/
chmod 444 $CLIENT_CERT_DIR/*.pem

# passwords
__ROOT_PASSWORD__=$(openssl rand -base64 128 | tr -dc a-z0-9 | head -c 48 ; echo '')
__ROOT_READONLY_PASSWORD__=$(openssl rand -base64 128 | tr -dc a-z0-9 | head -c 48 ; echo '')

# replica
__REPLICA_NAME__="$__NAMESPACE__"


# nodes
for NODE_ID in $( seq 0 $__NODES__ )
do
  NODE_PATH=$DIST_PATH/node${NODE_ID}
  mkdir -p $NODE_PATH
  cp -rf $PROJECT_PATH/template/node/* $NODE_PATH/
  cp -rf $CLIENT_CERT_DIR/*.pem $NODE_PATH/client-cert/
  cp -rf $CERT_DIR/node${NODE_ID}/*.pem $NODE_PATH/cert/

  sudo chmod 444 $NODE_PATH/cert/*.pem
  sudo chmod 444 $NODE_PATH/client-cert/*.pem
  sudo chmod 777 $NODE_PATH/*.sh
  sudo chmod 777 $NODE_PATH/scripts/*.sh

  sudo mv $NODE_PATH/scripts/init-replica.${__NODES_NZ__}N.sh $NODE_PATH/scripts/init-replica.sh
  sudo find $NODE_PATH/scripts/ -type f -name *N.sh -delete

  __NODE_MONGO_PORT__=$(eval echo \$__NODE${NODE_ID}_MONGO_PORT__)
  __NODE_X_EXPORTER_PORT__=$(eval echo \$__NODE${NODE_ID}_X_EXPORTER_PORT__)
  __NODE_X_WEB_UI_PORT__=$(eval echo \$__NODE${NODE_ID}_X_WEB_UI_PORT__)

  # not init node
  if [ $NODE_ID != "0" ]; then
    rm -rf $NODE_PATH/ini*.sh
    rm -rf $NODE_PATH/scripts/ini*.sh
  fi

  for FILE_TO_REPLACE in $(find $NODE_PATH -type f -regex ".*\.\(txt\|sh\|js\|yml\|sample\|conf\)"); do
    sed -i -e "s/__HOSTS_PORTS__/$__HOSTS_PORTS__/g" $FILE_TO_REPLACE

    sed -i -e "s/__NAMESPACE__/$__NAMESPACE__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE_ID__/$NODE_ID/g" $FILE_TO_REPLACE
    sed -i -e "s/__DOMAIN__/$__DOMAIN__/g" $FILE_TO_REPLACE

    sed -i -e "s/__ROOT_PASSWORD__/$__ROOT_PASSWORD__/g" $FILE_TO_REPLACE
    sed -i -e "s/__ROOT_READONLY_PASSWORD__/$__ROOT_READONLY_PASSWORD__/g" $FILE_TO_REPLACE

    sed -i -e "s/__NODE_MONGO_PORT__/$__NODE_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE_X_EXPORTER_PORT__/$__NODE_X_EXPORTER_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE_X_WEB_UI_PORT__/$__NODE_X_WEB_UI_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__REPLICA_NAME__/$__REPLICA_NAME__/g" $FILE_TO_REPLACE


    sed -i -e "s/__NODE0_MONGO_PORT__/$__NODE0_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE1_MONGO_PORT__/$__NODE1_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE2_MONGO_PORT__/$__NODE2_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE3_MONGO_PORT__/$__NODE3_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE4_MONGO_PORT__/$__NODE4_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE5_MONGO_PORT__/$__NODE5_MONGO_PORT__/g" $FILE_TO_REPLACE
    sed -i -e "s/__NODE6_MONGO_PORT__/$__NODE6_MONGO_PORT__/g" $FILE_TO_REPLACE

    if [ $__NODES_NZ__ == "3" ]; then
      sed '/5NODEREPLICA/d' -i $FILE_TO_REPLACE
      sed '/7NODEREPLICA/d' -i $FILE_TO_REPLACE
    elif [ $__NODES_NZ__ == "5" ]; then
      sed '/3NODEREPLICA/d' -i $FILE_TO_REPLACE
      sed '/7NODEREPLICA/d' -i $FILE_TO_REPLACE
    elif [ $__NODES_NZ__ == "7" ]; then
      sed '/3NODEREPLICA/d' -i $FILE_TO_REPLACE
      sed '/5NODEREPLICA/d' -i $FILE_TO_REPLACE
    fi

  done

  mv $NODE_PATH/env.sample $NODE_PATH/.env
  find $NODE_PATH -type f -name ".gitkeep" -delete
done
