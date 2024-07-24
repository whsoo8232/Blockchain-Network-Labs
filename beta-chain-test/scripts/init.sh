. ./setting.sh

trap 'echo "Error on line $LINENO"; exit 1' ERR
cleanup() {
    echo "Caught Ctrl+C. Killing active background processes and exiting."
    kill $(jobs -p)
    exit
}
trap 'cleanup' SIGINT


rm -rf "${NETWORK_DIR}" || echo "no network directory"
rm -rf "${CONFIG_DIR}" || echo "no network directory"
mkdir -p ${NETWORK_DIR}
mkdir -p ${CONFIG_DIR}
pkill geth || echo "No existing geth processes"
pkill beacon-chain || echo "No existing beacon-chain processes"
pkill validator || echo "No existing validator processes"
pkill bootnode || echo "No existing bootnode processes"


sed -i "s/NUM_NODES=${NUM_NODES}/NUM_NODES=0/" ./setting.sh
