#!/bin/bash

. ./setting.sh

get_bootnode_enode

NODE_DIR=../${NETWORK_DIR}/node-${1}

# Start geth execution client for this node
nohup ${GETH_BINARY} \
	--datadir=${NODE_DIR}/execution \
	--networkid=${CHAIN_ID:-11005} \
	--port=$((${GETH_NETWORK_PORT} + ${1})) \
	--bootnodes=${bootnode_enode} \
	--http \
	--http.api=eth,net,engine,admin,web3 \
	--http.addr=127.0.0.1 \
	--http.corsdomain="*" \
	--http.port=$((${GETH_HTTP_PORT} + ${1})) \
	--metrics.port=$((${GETH_METRICS_PORT} + ${1})) \
	--ws \
	--ws.api=eth,net,engine,admin,web3 \
	--ws.addr=127.0.0.1 \
	--ws.origins="*" \
	--ws.port=$((${GETH_WS_PORT} + ${1})) \
	--authrpc.vhosts="*" \
	--authrpc.addr=127.0.0.1 \
	--authrpc.jwtsecret=${NODE_DIR}/execution/jwt.hex \
	--authrpc.port=$((${GETH_AUTH_RPC_PORT} + ${1})) \
	--password=${geth_pw_file} \
	--identity=node-${1} \
	--verbosity=3 \
	--syncmode=full > "${NODE_DIR}/logs/geth.log" 2>&1 &

