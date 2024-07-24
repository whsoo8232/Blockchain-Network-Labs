#!/bin/bash
. ./setting.sh

${PRYSM_CTL_BINARY} testnet generate-genesis \
    --fork=deneb \
    --num-validators=5 \
    --chain-config-file=../config.yml \
    --geth-genesis-json-in=../genesis.json \
    --output-ssz=${NETWORK_DIR}/genesis.ssz \
    --geth-genesis-json-out=${NETWORK_DIR}/genesis.json