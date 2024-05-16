#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq first."
    exit 1
fi
# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl first."
    exit 1
fi

. ./bin/.setting.sh

#trap 'echo "Error on line $LINENO"; exit 1' ERR
## Function to handle the cleanup
#cleanup() {
#    echo "Caught Ctrl+C. Killing active background processes and exiting."
#    kill $(jobs -p)  # Kills all background processes started in this script
#    exit
#}
## Trap the SIGINT signal and call the cleanup function when it's caught
#trap 'cleanup' SIGINT

# Reset the data from any previous runs and kill any hanging runtimes
rm -rf "${NETWORK_DIR}" || echo "no network directory"
mkdir -p ${NETWORK_DIR}
#pkill geth || echo "No existing geth processes"
#pkill beacon-chain || echo "No existing beacon-chain processes"
#pkill validator || echo "No existing validator processes"
#pkill bootnode || echo "No existing bootnode processes"
./bin/stopall.sh

# Create the bootnode for execution client peer discovery. 
# Not a production grade bootnode. Does not do peer discovery for consensus client
mkdir -p ${NETWORK_DIR}/bootnode

${GETH_BOOTNODE_BINARY} -genkey ${NETWORK_DIR}/bootnode/nodekey

#${GETH_BOOTNODE_BINARY} \
#    -nodekey ${NETWORK_DIR}/bootnode/nodekey \
#    -addr=:${GETH_BOOTNODE_PORT} \
#    -verbosity=5 > "${NETWORK_DIR}/bootnode/bootnode.log" 2>&1 &
#
#sleep 2
## Get the ENODE from the first line of the logs for the bootnode
#bootnode_enode=$(head -n 1 ${NETWORK_DIR}/bootnode/bootnode.log)
## Check if the line begins with "enode"
#if [[ "${bootnode_enode}" == enode* ]]; then
#    echo "bootnode enode is: ${bootnode_enode}"
#else
#    echo "The bootnode enode was not found. Exiting."
#    exit 1
#fi
./bin/startboot.sh
if [ "$?" != "0" ]; then
        exit 1
fi

## Generate the genesis. This will generate validators based
## on https://github.com/ethereum/eth2.0-pm/blob/a085c9870f3956d6228ed2a40cd37f0c6580ecd7/interop/mocked_start/README.md
#${PRYSM_CTL_BINARY} testnet generate-genesis \
#--fork=deneb \
#--num-validators=${NUM_NODES} \
#--chain-config-file=./config.yml \
#--geth-genesis-json-in=./genesis.json \
#--output-ssz=${NETWORK_DIR}/genesis.ssz \
#--geth-genesis-json-out=${NETWORK_DIR}/genesis.json
./bin/create_genesis.sh

## Create the validators in a loop
#for (( i=0; i<${NUM_NODES}; i++ )); do
#    NODE_DIR=${NETWORK_DIR}/node-${i}
#    mkdir -p ${NODE_DIR}/execution
#    mkdir -p ${NODE_DIR}/consensus
#    mkdir -p ${NODE_DIR}/logs
#
#    # We use an empty password. Do not do this in production
#    geth_pw_file="${NODE_DIR}/geth_password.txt"
#    echo "" > "$geth_pw_file"
#
#    # Copy the same genesis and inital config the node's directories
#    # All nodes must have the same genesis otherwise they will reject eachother
#    cp ./config.yml ${NODE_DIR}/consensus/config.yml
#    cp ${NETWORK_DIR}/genesis.ssz ${NODE_DIR}/consensus/genesis.ssz
#    cp ${NETWORK_DIR}/genesis.json ${NODE_DIR}/execution/genesis.json
#
#    # Create the secret keys for this node and other account details
#    ${GETH_BINARY} account new --datadir "${NODE_DIR}/execution" --password "$geth_pw_file"
#
#    echo "datadir=${NODE_DIR}/execution init start"
#    # Initialize geth for this node. Geth uses the genesis.json to write some initial state
#    ${GETH_BINARY} init \
#      --datadir=${NODE_DIR}/execution \
#      ${NODE_DIR}/execution/genesis.json
#    echo "datadir=${NODE_DIR}/execution init end"
#done
./bin/create_node.sh

# Create the geth node in a loop
#for (( i=0; i<${NUM_NODES}; i++ )); do
#    NODE_DIR=${NETWORK_DIR}/node-${i}
#    # Start geth execution client for this node
#    ${GETH_BINARY} \
#      --networkid=${CHAIN_ID:-6832} \
#      --http \
#      --http.api=eth,net,web3 \
#      --http.addr=127.0.0.1 \
#      --http.corsdomain="*" \
#      --http.port=$((${GETH_HTTP_PORT} + ${i})) \
#      --port=$((${GETH_NETWORK_PORT} + ${i})) \
#      --metrics.port=$((${GETH_METRICS_PORT} + ${i})) \
#      --ws \
#      --ws.api=eth,net,web3 \
#      --ws.addr=127.0.0.1 \
#      --ws.origins="*" \
#      --ws.port=$((${GETH_WS_PORT} + ${i})) \
#      --authrpc.vhosts="*" \
#      --authrpc.addr=127.0.0.1 \
#      --authrpc.jwtsecret=${NODE_DIR}/execution/jwtsecret \
#      --authrpc.port=$((${GETH_AUTH_RPC_PORT} + ${i})) \
#      --datadir=${NODE_DIR}/execution \
#      --password=${geth_pw_file} \
#      --bootnodes=${bootnode_enode} \
#      --identity=node-${i} \
#      --maxpendpeers=${NUM_NODES} \
#      --verbosity=3 \
#      --syncmode=full > "${NODE_DIR}/logs/geth.log" 2>&1 &
#done
for (( i=0; i<${NUM_NODES}; i++ )); do
	./bin/startnode.sh ${i}
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
      --force-clear-db \
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
      --enable-debug-rpc-endpoints \
      > "${NODE_DIR}/logs/beacon.log" 2>&1 &
#	./bin/startbeacon.sh ${i}
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
      --chain-config-file=${NODE_DIR}/consensus/config.yml \
      > "${NODE_DIR}/logs/validator.log" 2>&1 &


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
tail -f ${NETWORK_DIR}/node-?/logs/*.log
