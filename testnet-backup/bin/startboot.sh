#!/bin/bash

. ./bin/.setting.sh

nohup ${GETH_BOOTNODE_BINARY} \
    -nodekey ${NETWORK_DIR}/bootnode/nodekey \
    -addr=:${GETH_BOOTNODE_PORT} \
    -verbosity=5 > "${NETWORK_DIR}/bootnode/bootnode.log" 2>&1 &

sleep 2
# Get the ENODE from the first line of the logs for the bootnode
get_bootnode_enode
# Check if the line begins with "enode"
if [[ "${bootnode_enode}" == enode* ]]; then
    echo "bootnode enode is: ${bootnode_enode}"
else
    echo "The bootnode enode was not found. Exiting."
    exit 1
fi
