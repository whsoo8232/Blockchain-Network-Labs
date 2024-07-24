. ./setting.sh

pkill geth
pkill bootnode


rm -rf ../network
rm -rf ../config


rm -rf node-*
sed -i "s/NUM_NODES=${NUM_NODES}/NUM_NODES=0/" ./setting.sh


mkdir -p ../${CONFIG_DIR}
mkdir -p ../${NETWORK_DIR}


${PRYSM_CTL_BINARY} testnet generate-genesis \
    --fork=deneb \
    --num-validators=10 \
    --chain-config-file=../config.yml \
    --geth-genesis-json-in=../genesis.json \
    --output-ssz=../${NETWORK_DIR}/genesis.ssz \
    --geth-genesis-json-out=../${NETWORK_DIR}/genesis.json