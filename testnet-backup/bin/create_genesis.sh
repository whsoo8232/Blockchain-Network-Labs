#!/bin/bash

. ./bin/.setting.sh

# Generate the genesis. This will generate validators based
# on https://github.com/ethereum/eth2.0-pm/blob/a085c9870f3956d6228ed2a40cd37f0c6580ecd7/interop/mocked_start/README.md
${PRYSM_CTL_BINARY} testnet generate-genesis \
--fork=deneb \
--num-validators=${NUM_NODES} \
--chain-config-file=./config.yml \
--geth-genesis-json-in=./genesis.json \
--output-ssz=${NETWORK_DIR}/genesis.ssz \
--geth-genesis-json-out=${NETWORK_DIR}/genesis.json
