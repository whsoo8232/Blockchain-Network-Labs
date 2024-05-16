#!/bin/bash

. ./0_setting.sh

pkill geth || echo "No existing geth processes"
pkill beacon-chain || echo "No existing beacon-chain processes"
pkill validator || echo "No existing validator processes"
pkill bootnode || echo "No existing bootnode processes"

${GETH_BOOTNODE_BINARY} \
    -nodekey ${NETWORK_DIR}/bootnode/nodekey \
    -addr=:${GETH_BOOTNODE_PORT} \
    -verbosity=5 > "${NETWORK_DIR}/bootnode/bootnode.log" 2>&1 &

sleep 2
# Get the ENODE from the first line of the logs for the bootnode
bootnode_enode=$(head -n 1 ${NETWORK_DIR}/bootnode/bootnode.log)
# Check if the line begins with "enode"
if [[ "${bootnode_enode}" == enode* ]]; then
    echo "bootnode enode is: ${bootnode_enode}"
else
    echo "The bootnode enode was not found. Exiting."
    exit 1
fi

# Create the validators in a loop
for (( i=0; i<${NUM_NODES}; i++ )); do
    NODE_DIR=${NETWORK_DIR}/node-${i}
    # Start geth execution client for this node
    ${GETH_BINARY} \
      --networkid=${CHAIN_ID:-6832} \
      --http \
      --http.api=eth,net,web3 \
      --http.addr=127.0.0.1 \
      --http.corsdomain="*" \
      --http.port=$((${GETH_HTTP_PORT} + ${i})) \
      --port=$((${GETH_NETWORK_PORT} + ${i})) \
      --metrics.port=$((${GETH_METRICS_PORT} + ${i})) \
      --ws \
      --ws.api=eth,net,web3 \
      --ws.addr=127.0.0.1 \
      --ws.origins="*" \
      --ws.port=$((${GETH_WS_PORT} + ${i})) \
      --authrpc.vhosts="*" \
      --authrpc.addr=127.0.0.1 \
      --authrpc.jwtsecret=${NODE_DIR}/execution/jwtsecret \
      --authrpc.port=$((${GETH_AUTH_RPC_PORT} + ${i})) \
      --datadir=${NODE_DIR}/execution \
      --password=${geth_pw_file} \
      --bootnodes=${bootnode_enode} \
      --identity=node-${i} \
      --maxpendpeers=${NUM_NODES} \
      --verbosity=3 \
      --syncmode=full > "${NODE_DIR}/logs/geth.log" 2>&1 &
done

# Create the validators in a loop
for (( i=0; i<${NUM_NODES}; i++ )); do
    sleep 5
    NODE_DIR=${NETWORK_DIR}/node-${i}
    # Start prysm consensus client for this node
    ${PRYSM_BEACON_BINARY} \
      --datadir=${NODE_DIR}/consensus/beacondata \
      --min-sync-peers=${MIN_SYNC_PEERS} \
      --genesis-state=${NODE_DIR}/consensus/genesis.ssz \
      --bootstrap-node=${PRYSM_BOOTSTRAP_NODE} \
      --interop-eth1data-votes \
      --chain-config-file=${NODE_DIR}/consensus/config.yml \
      --contract-deployment-block=0 \
      --chain-id=${CHAIN_ID:-6832} \
      --rpc-host=127.0.0.1 \
      --rpc-port=$((${PRYSM_BEACON_RPC_PORT} + ${i})) \
      --grpc-gateway-host=127.0.0.1 \
      --grpc-gateway-port=$((${PRYSM_BEACON_GRPC_GATEWAY_PORT} + ${i})) \
      --execution-endpoint=http://localhost:$((${GETH_AUTH_RPC_PORT} + ${i})) \
      --accept-terms-of-use \
      --jwt-secret=${NODE_DIR}/execution/jwtsecret \
      --suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 \
      --minimum-peers-per-subnet=0 \
      --p2p-tcp-port=$((${PRYSM_BEACON_P2P_TCP_PORT} + ${i})) \
      --p2p-udp-port=$((${PRYSM_BEACON_P2P_UDP_PORT} + ${i})) \
      --monitoring-port=$((${PRYSM_BEACON_MONITORING_PORT} + ${i})) \
      --verbosity=info \
      --slasher \
      --enable-debug-rpc-endpoints > "${NODE_DIR}/logs/beacon.log" 2>&1 &

    # Start prysm validator for this node. Each validator node will
    # manage 1 validator
    ${PRYSM_VALIDATOR_BINARY} \
      --beacon-rpc-provider=localhost:$((${PRYSM_BEACON_RPC_PORT} + ${i})) \
      --datadir=${NODE_DIR}/consensus/validatordata \
      --accept-terms-of-use \
      --interop-num-validators=1 \
      --interop-start-index=${i} \
      --rpc-port=$((${PRYSM_VALIDATOR_RPC_PORT} + ${i})) \
      --grpc-gateway-port=$((${PRYSM_VALIDATOR_GRPC_GATEWAY_PORT} + ${i})) \
      --monitoring-port=$((${PRYSM_VALIDATOR_MONITORING_PORT} + ${i})) \
      --graffiti="node-${i}" \
      --chain-config-file=${NODE_DIR}/consensus/config.yml > "${NODE_DIR}/logs/validator.log" 2>&1 &


    # Check if the PRYSM_BOOTSTRAP_NODE variable is already set
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
done

# You might want to change this if you want to tail logs for other nodes
# Logs for all nodes can be found in `./network/node-*/logs`
#tail -f ${NETWORK_DIR}/node-?/logs/geth.log
tail -f ${NETWORK_DIR}/node-?/logs/*.log
