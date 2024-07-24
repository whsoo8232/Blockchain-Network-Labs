#!/bin/bash

. ./setting.sh

NODE_DIR=../${NETWORK_DIR}/node-${1}

mkdir -p ${NODE_DIR}/consensus/beacon
mkdir -p ${NODE_DIR}/consensus/validator

if [ "${1}" != "0" ]; then
		if [[ -z "${PRYSM_BOOTSTRAP_NODE}" ]]; then
			sleep 5
			PRYSM_BOOTSTRAP_NODE=$(curl -s localhost:4100/eth/v1/node/identity | jq -r '.data.enr')
			if [[ ${PRYSM_BOOTSTRAP_NODE} == enr* ]]; then
				echo "PRYSM_BOOTSTRAP_NODE is valid: ${PRYSM_BOOTSTRAP_NODE}"
			else
				echo "PRYSM_BOOTSTRAP_NODE does NOT start with enr"
				exit 1
			fi
		fi
	fi

# Start prysm consensus client for this node
nohup ${PRYSM_BINARY} beacon-chain \
	--datadir=${NODE_DIR}/consensus/beacon \
	--bootstrap-node=${PRYSM_BOOTSTRAP_NODE} \
	--interop-eth1data-votes \
	--min-sync-peers=${MIN_SYNC_PEERS} \
	--genesis-state=$NODE_DIR/consensus/genesis.ssz \
	--force-clear-db \
	--chain-config-file=${NODE_DIR}/consensus/config.yml \
	--contract-deployment-block=0 \
	--chain-id=${CHAIN_ID:-11005} \
	--rpc-host=127.0.0.1 \
	--rpc-port=$((${PRYSM_BEACON_RPC_PORT} + ${1})) \
	--grpc-gateway-host=127.0.0.1 \
	--grpc-gateway-port=$((${PRYSM_BEACON_GRPC_GATEWAY_PORT} + ${1})) \
	--execution-endpoint=http://localhost:$((${GETH_AUTH_RPC_PORT} + ${1})) \
	--accept-terms-of-use \
	--jwt-secret=${NODE_DIR}/execution/jwt.hex \
	--suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 \
	--minimum-peers-per-subnet=0 \
	--p2p-tcp-port=$((${PRYSM_BEACON_P2P_TCP_PORT} + ${1})) \
	--p2p-udp-port=$((${PRYSM_BEACON_P2P_UDP_PORT} + ${1})) \
	--monitoring-port=$((${PRYSM_BEACON_MONITORING_PORT} + ${1})) \
	--verbosity=info \
	--slasher \
	--enable-debug-rpc-endpoints \
	> "${NODE_DIR}/logs/beacon.log" 2>&1 &

# Start prysm validator for this node. Each validator node will
# manage 1 validator
#nohup ${PRYSM_BINARY} \
#	--beacon-rpc-provider=http://localhost:$((${PRYSM_BEACON_RPC_PORT} + ${1})) \
#	--datadir=${NODE_DIR}/consensus/validator \
#	--accept-terms-of-use \
#	--interop-num-validators=1 \
#	--interop-start-index=${1} \
#	--rpc-port=$((${PRYSM_VALIDATOR_RPC_PORT} + ${1})) \
#	--grpc-gateway-port=$((${PRYSM_VALIDATOR_GRPC_GATEWAY_PORT} + ${1})) \
#	--monitoring-port=$((${PRYSM_VALIDATOR_MONITORING_PORT} + ${1})) \
#	--graffiti="node-${1}" \
#	--chain-config-file=${NODE_DIR}/consensus/config.yml \
#	> "${NODE_DIR}/logs/validator.log" 2>&1 &