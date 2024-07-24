#!/bin/bash
. ./setting.sh

NODE_DIR=${NETWORK_DIR}/node-${1}

mkdir -p ${NODE_DIR}/consensus/beacon
mkdir -p ${NODE_DIR}/consensus/validator


PRYSM_BOOTSTRAP_NODE0=$(curl -s localhost:4100/eth/v1/node/identity | jq -r '.data.enr')
PRYSM_BOOTSTRAP_NODE1=$(curl -s localhost:4101/eth/v1/node/identity | jq -r '.data.enr')
PRYSM_BOOTSTRAP_NODE2=$(curl -s localhost:4102/eth/v1/node/identity | jq -r '.data.enr')


nohup ${PRYSM_BEACON_BINARY} \
	--datadir=${NODE_DIR}/consensus/beacon \
	--min-sync-peers=${MIN_SYNC_PEERS} \
	--genesis-state=${NODE_DIR}/consensus/genesis.ssz \
	--bootstrap-node=${PRYSM_BOOTSTRAP_NODE0} \
	--bootstrap-node=${PRYSM_BOOTSTRAP_NODE1} \
	--bootstrap-node=${PRYSM_BOOTSTRAP_NODE2} \
	--interop-eth1data-votes \
	--chain-config-file=${NODE_DIR}/consensus/config.yml \
	--contract-deployment-block=0 \
	--chain-id=${CHAIN_ID} \
	--rpc-host=127.0.0.1 \
	--rpc-port=$((${PRYSM_BEACON_RPC_PORT} + ${1})) \
	--grpc-gateway-host=127.0.0.1 \
	--grpc-gateway-port=$((${PRYSM_BEACON_GRPC_GATEWAY_PORT} + ${1})) \
	--execution-endpoint=http://localhost:$((${GETH_AUTH_RPC_PORT} + ${1})) \
	--accept-terms-of-use \
	--jwt-secret=${NODE_DIR}/execution/jwtsecret \
	--suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 \
	--minimum-peers-per-subnet=0 \
	--p2p-tcp-port=$((${PRYSM_BEACON_P2P_TCP_PORT} + ${1})) \
	--p2p-udp-port=$((${PRYSM_BEACON_P2P_UDP_PORT} + ${1})) \
	--monitoring-port=$((${PRYSM_BEACON_MONITORING_PORT} + ${1})) \
	--verbosity=info \
	--slasher \
	--enable-debug-rpc-endpoints \
	> "${NODE_DIR}/logs/beacon.log" 2>&1 &



#Start prysm validator for this node. Each validator node will
#manage 1 validator
nohup ${PRYSM_VALIDATOR_BINARY} \
	--beacon-rpc-provider=localhost:$((${PRYSM_BEACON_RPC_PORT} + ${1})) \
	--datadir=${NODE_DIR}/consensus/validator \
	--accept-terms-of-use \
	--interop-num-validators=1 \
	--interop-start-index=${1} \
	--rpc-port=$((${PRYSM_VALIDATOR_RPC_PORT} + ${1})) \
	--grpc-gateway-port=$((${PRYSM_VALIDATOR_GRPC_GATEWAY_PORT} + ${1})) \
	--monitoring-port=$((${PRYSM_VALIDATOR_MONITORING_PORT} + ${1})) \
	--graffiti="node-${1}" \
	--chain-config-file=${NODE_DIR}/consensus/config.yml \
	> "${NODE_DIR}/logs/validator.log" 2>&1 &