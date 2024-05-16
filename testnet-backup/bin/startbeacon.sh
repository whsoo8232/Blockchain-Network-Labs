#!/bin/bash

. ./bin/.setting.sh

#PRYSM_BOOTSTRAP_NODE=enr:-MK4QKw5a9Ifu2a2kb-rDlmZvVeEbuF4dnVq71xFSQ5cfRekcXbGMgweXlS2hVbHeA9RNs27C9gcgizeCcuiFsD0Y-aGAY84Mi5Kh2F0dG5ldHOIAAAAAADAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQIOOK4RLYkKKMVCtFOmCun8cSbazAtimZj6hrYWqE4jSYhzeW5jbmV0cwCDdGNwghBog3VkcIIQzA
function start_beacon() {
	sleep 5 # sleep to let the prysm node set up
	# Check if the PRYSM_BOOTSTRAP_NODE variable is already set
	if [ "${1}" != "0" ]; then
		if [[ -z "${PRYSM_BOOTSTRAP_NODE}" ]]; then
			sleep 5 # sleep to let the prysm node set up
			# If PRYSM_BOOTSTRAP_NODE is not set, execute the command and capture the result into the variable
			# This allows subsequent nodes to discover the first node, treating it as the bootnode
			PRYSM_BOOTSTRAP_NODE=$(curl -s localhost:4100/eth/v1/node/identity | jq -r '.data.enr')
			# Check if the result starts with enr
			if [[ ${PRYSM_BOOTSTRAP_NODE} == enr* ]]; then
				echo "PRYSM_BOOTSTRAP_NODE is valid: ${PRYSM_BOOTSTRAP_NODE}"
			else
				echo "PRYSM_BOOTSTRAP_NODE does NOT start with enr"
				exit 1
			fi
		fi
	fi
	NODE_DIR=${NETWORK_DIR}/node-${1}
	if [ "${1}" == "0" ]; then
		PRYSM_BOOTSTRAP_NODE=
	fi
	# Start prysm consensus client for this node
	nohup ${PRYSM_BEACON_BINARY} \
	--datadir=${NODE_DIR}/consensus/beacondata \
	--min-sync-peers=${MIN_SYNC_PEERS} \
	--genesis-state=${NODE_DIR}/consensus/genesis.ssz \
	--bootstrap-node=${PRYSM_BOOTSTRAP_NODE} \
	--force-clear-db \
	--interop-eth1data-votes \
	--chain-config-file=${NODE_DIR}/consensus/config.yml \
	--contract-deployment-block=0 \
	--chain-id=${CHAIN_ID:-6832} \
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

	# Start prysm validator for this node. Each validator node will
	# manage 1 validator
	nohup ${PRYSM_VALIDATOR_BINARY} \
	--beacon-rpc-provider=localhost:$((${PRYSM_BEACON_RPC_PORT} + ${1})) \
	--datadir=${NODE_DIR}/consensus/validatordata \
	--accept-terms-of-use \
	--interop-num-validators=1 \
	--interop-start-index=${1} \
	--rpc-port=$((${PRYSM_VALIDATOR_RPC_PORT} + ${1})) \
	--grpc-gateway-port=$((${PRYSM_VALIDATOR_GRPC_GATEWAY_PORT} + ${1})) \
	--monitoring-port=$((${PRYSM_VALIDATOR_MONITORING_PORT} + ${1})) \
	--graffiti="node-${1}" \
	--chain-config-file=${NODE_DIR}/consensus/config.yml \
	> "${NODE_DIR}/logs/validator.log" 2>&1 &

	# Check if the PRYSM_BOOTSTRAP_NODE variable is already set
#	if [[ -z "${PRYSM_BOOTSTRAP_NODE}" ]]; then
#		sleep 5 # sleep to let the prysm node set up
#		# If PRYSM_BOOTSTRAP_NODE is not set, execute the command and capture the result into the variable
#		# This allows subsequent nodes to discover the first node, treating it as the bootnode
#		PRYSM_BOOTSTRAP_NODE=$(curl -s localhost:4100/eth/v1/node/identity | jq -r '.data.enr')
#		# Check if the result starts with enr
#		if [[ ${PRYSM_BOOTSTRAP_NODE} == enr* ]]; then
#			echo "PRYSM_BOOTSTRAP_NODE is valid: ${PRYSM_BOOTSTRAP_NODE}"
#		else
#			echo "PRYSM_BOOTSTRAP_NODE does NOT start with enr"
#			exit 1
#		fi
#	fi
}

if [ "${#}" == "1" ]; then
	if [ "${1}" == "all" ]; then
		# Create the validators in a loop
		for (( i=0; i<${NUM_NODES}; i++ )); do
			start_beacon ${i}
		done
	else
		start_beacon ${1}
	fi
else
	echo "parameter count must be 1 but ${#}"
	exit 1
fi
