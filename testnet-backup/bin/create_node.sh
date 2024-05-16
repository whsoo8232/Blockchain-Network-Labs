#!/bin/bash

. ./bin/.setting.sh

# Create the validators in a loop
for (( i=0; i<${NUM_NODES}; i++ )); do
    NODE_DIR=${NETWORK_DIR}/node-${i}
    mkdir -p ${NODE_DIR}/execution
    mkdir -p ${NODE_DIR}/consensus
    mkdir -p ${NODE_DIR}/logs

    # We use an empty password. Do not do this in production
    geth_pw_file="${NODE_DIR}/geth_password.txt"
    echo "" > "$geth_pw_file"

    # Copy the same genesis and inital config the node's directories
    # All nodes must have the same genesis otherwise they will reject eachother
    cp ./config.yml ${NODE_DIR}/consensus/config.yml
    cp ${NETWORK_DIR}/genesis.ssz ${NODE_DIR}/consensus/genesis.ssz
    cp ${NETWORK_DIR}/genesis.json ${NODE_DIR}/execution/genesis.json

    # Create the secret keys for this node and other account details
    ${GETH_BINARY} account new --datadir "${NODE_DIR}/execution" --password "$geth_pw_file"

    echo "datadir=${NODE_DIR}/execution init start"
    # Initialize geth for this node. Geth uses the genesis.json to write some initial state
    ${GETH_BINARY} init \
      --datadir=${NODE_DIR}/execution \
      ${NODE_DIR}/execution/genesis.json
    echo "datadir=${NODE_DIR}/execution init end"
done
