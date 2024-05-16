#!/bin/bash

. ./bin/.setting.sh

function start_node() {
	get_bootnode_enode
#	echo ${bootnode_enode}

	NODE_DIR=${NETWORK_DIR}/node-${1}
	# Start geth execution client for this node
	nohup ${GETH_BINARY} \
	--networkid=${CHAIN_ID:-6832} \
	--http \
	--http.api=eth,net,web3 \
	--http.addr=127.0.0.1 \
	--http.corsdomain="*" \
	--http.port=$((${GETH_HTTP_PORT} + ${1})) \
	--port=$((${GETH_NETWORK_PORT} + ${1})) \
	--metrics.port=$((${GETH_METRICS_PORT} + ${1})) \
	--ws \
	--ws.api=eth,net,web3 \
	--ws.addr=127.0.0.1 \
	--ws.origins="*" \
	--ws.port=$((${GETH_WS_PORT} + ${1})) \
	--authrpc.vhosts="*" \
	--authrpc.addr=127.0.0.1 \
	--authrpc.jwtsecret=${NODE_DIR}/execution/jwtsecret \
	--authrpc.port=$((${GETH_AUTH_RPC_PORT} + ${1})) \
	--datadir=${NODE_DIR}/execution \
	--password=${geth_pw_file} \
	--bootnodes=${bootnode_enode} \
	--identity=node-${1} \
	--maxpendpeers=${NUM_NODES} \
	--verbosity=3 \
	--syncmode=full > "${NODE_DIR}/logs/geth.log" 2>&1 &
}

if [ "${#}" == "1" -a "${1}" == "all" ]; then
	start_node 0
	start_node 1
	start_node 2
elif [ "${#}" == "1" ]; then
	start_node ${1}
else
	echo "parameter count must be 1 but ${#}"
	exit 1
fi
