./setting.sh

BOOTNODE_NAME=Alpha
BOOTNODE_DIR=bootnode-${BOOTNODE_NAME}

# Create the bootnode for execution client peer discovery. 
# Not a production grade bootnode. Does not do peer discovery for consensus client
mkdir -p ${NETWORK_DIR}/${BOOTNODE_DIR}


${GETH_BOOTNODE_BINARY} -genkey ${NETWORK_DIR}/${BOOTNODE_DIR}/nodekey


nohup ${GETH_BOOTNODE_BINARY} \
    -nodekey ${NETWORK_DIR}/${BOOTNODE_DIR}/nodekey \
    -addr=:${GETH_BOOTNODE_PORT} \
    -verbosity=5 > "${NETWORK_DIR}/${BOOTNODE_DIR}/bootnode.log" 2>&1 &


sleep 2
# Get the ENODE from the first line of the logs for the bootnode
get_bootnode_enode
# Check if the line begins with "enode"
if [[ "${bootnode_enode}" == enode* ]]; then
    echo "${BOOTNODE_DIR} enode is: ${bootnode_enode}"
else
    echo "The ${BOOTNODE_DIR} enode was not found. Exiting."
    exit 1
fi

if [ "$?" != "0" ]; then
	exit 1
fi
