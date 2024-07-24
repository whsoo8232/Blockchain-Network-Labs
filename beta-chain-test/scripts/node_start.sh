#!/bin/bash
. ./setting.sh

get_bootnode_enode

NODE_DIR=${NETWORK_DIR}/node-${1}

# Start geth execution client for this node
nohup ${GETH_BINARY} \
	--networkid=${CHAIN_ID} \
	--http \
	--http.api=eth,net,engine,admin,web3 \
	--http.addr=127.0.0.1 \
	--http.corsdomain="*" \
	--http.port=$((${GETH_HTTP_PORT} + ${1})) \
	--port=$((${GETH_NETWORK_PORT} + ${1})) \
	--metrics.port=$((${GETH_METRICS_PORT} + ${1})) \
	--ws \
	--ws.api=eth,net,engine,admin,web3 \
	--ws.addr=127.0.0.1 \
	--ws.origins="*" \
	--ws.port=$((${GETH_WS_PORT} + ${1})) \
	--authrpc.vhosts="*" \
	--authrpc.addr=127.0.0.1 \
	--authrpc.jwtsecret=${NODE_DIR}/execution/jwtsecret \
	--authrpc.port=$((${GETH_AUTH_RPC_PORT} + ${1})) \
	--datadir=${NODE_DIR}/execution \
	--password=${NODE_DIR}/geth_password.txt \
	--bootnodes=${bootnode_enode} \
	--identity=node-${1} \
	--verbosity=3 \
	--syncmode=full > "${NODE_DIR}/logs/geth.log" 2>&1 &

