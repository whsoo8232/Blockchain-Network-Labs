#!/bin/bash

NUM_NODES=0

# NETWORK_DIR is where all files for the testnet will be stored,
# including logs and storage
CONFIG_DIR=config
NETWORK_DIR=network
BOOTNODE_DIR=bootnode

# Port information. All ports will be incremented upon
# with more validators to prevent port conflicts on a single machine
GETH_BOOTNODE_PORT=30301

GETH_HTTP_PORT=8000
GETH_WS_PORT=8100
GETH_AUTH_RPC_PORT=8200
GETH_METRICS_PORT=8300
GETH_NETWORK_PORT=8400

PRYSM_BEACON_RPC_PORT=4000
PRYSM_BEACON_GRPC_GATEWAY_PORT=4100
PRYSM_BEACON_P2P_TCP_PORT=4200
PRYSM_BEACON_P2P_UDP_PORT=4300
PRYSM_BEACON_MONITORING_PORT=4400

PRYSM_VALIDATOR_RPC_PORT=7000
PRYSM_VALIDATOR_GRPC_GATEWAY_PORT=7100
PRYSM_VALIDATOR_MONITORING_PORT=7200

# Set Paths for your binaries. Configure as you wish, particularly
# if you're developing on a local fork of geth/prysm
GETH_BINARY=../dependencies/go-ethereum_v1.13.12/build/bin/geth
GETH_BOOTNODE_BINARY=../dependencies/go-ethereum_v1.13.12/build/bin/bootnode

PRYSM_CTL_BINARY=../dependencies/prysm_v4.2.1/bazel-bin/cmd/prysmctl/prysmctl_/prysmctl
PRYSM_BEACON_BINARY=../dependencies/prysm_v4.2.1/bazel-bin/cmd/beacon-chain/beacon-chain_/beacon-chain
PRYSM_VALIDATOR_BINARY=../dependencies/prysm_v4.2.1/bazel-bin/cmd/validator/validator_/validator

# The prysm bootstrap node is set after the first loop, as the first
# node is the bootstrap node. This is used for consensus client discovery
PRYSM_BOOTSTRAP_NODE=

# Get the ENODE from the first line of the logs for the bootnode
bootnode_enode=""
function get_bootnode_enode() {
	bootnode_enode=$(head -n 1 ../${NETWORK_DIR}/${BOOTNODE_DIR}/bootnode.log)
}
