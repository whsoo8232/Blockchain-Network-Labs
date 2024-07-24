#!/bin/bash

. ./setting.sh


NODE_DIR=${NETWORK_DIR}/node-${1}
mkdir -p ../${NODE_DIR}
mkdir -p ../${NODE_DIR}/execution
mkdir -p ../${NODE_DIR}/consensus
mkdir -p ../${NODE_DIR}/logs


geth_pw_file="../${NODE_DIR}/geth_password.txt"
echo "" > "$geth_pw_file"


cp ../config.yml ../${NODE_DIR}/consensus/.
cp ../${NETWORK_DIR}/genesis.ssz ${NODE_DIR}/consensus/genesis.ssz
cp ../${NETWORK_DIR}/genesis.json ../${NODE_DIR}/execution/.


${GETH_BINARY} init \
  --datadir=../${NODE_DIR}/execution \
  ../${NODE_DIR}/execution/genesis.json
echo "datadir=../${NODE_DIR}/execution init end"


${GETH_BINARY} account new --datadir "../${NODE_DIR}/execution" --password "${geth_pw_file}"
echo "datadir=../${NODE_DIR}/execution init start"


declare -i NEW_NUM_NODES 
NEW_NUM_NODES=${NUM_NODES}+1
sed -i "s/NUM_NODES=${NUM_NODES}/NUM_NODES=${NEW_NUM_NODES}/" ./setting.sh