#!/bin/bash
. ./setting.sh

NUM_NODE=${1}

get_bootnode_enode

#echo ${bootnode_enode}
NODE_DIR=../${NETWORK_DIR}/node-${NUM_NODE}

# Start geth execution client for this node
nohup ${GETH_BINARY} \
	--networkid=${CHAIN_ID:-11005} \
	--http \
	--http.api=eth,net,web3 \
	--http.addr=127.0.0.1 \
	--http.corsdomain="*" \
	--http.port=$((${GETH_HTTP_PORT} + ${NUM_NODE})) \
	--port=$((${GETH_NETWORK_PORT} + ${NUM_NODE})) \
	--metrics.port=$((${GETH_METRICS_PORT} + ${NUM_NODE})) \
	--ws \
	--ws.api=eth,net,web3 \
	--ws.addr=127.0.0.1 \
	--ws.origins="*" \
	--ws.port=$((${GETH_WS_PORT} + ${NUM_NODE})) \
	--authrpc.vhosts="*" \
	--authrpc.addr=127.0.0.1 \
	--authrpc.jwtsecret=${NODE_DIR}/execution/jwtsecret \
	--authrpc.port=$((${GETH_AUTH_RPC_PORT} + ${NUM_NODE})) \
	--datadir=${NODE_DIR}/execution \
	--password=${geth_pw_file} \
	--bootnodes=${bootnode_enode} \
	--identity=node-${NUM_NODE} \
	--maxpendpeers=${NUM_NODE} \
	--verbosity=3 \
	--syncmode=full > "${NODE_DIR}/logs/geth.log" 2>&1 &

declare -i NEW_NUM_NODES 
NEW_NUM_NODES=${NUM_NODES}+1
sed -i "s/NUM_NODES=${NUM_NODES}/NUM_NODES=${NEW_NUM_NODES}/" ./setting.sh

