+ set -o pipefail
+ command -v jq
+ command -v curl
+ CONFIG_DIR=./config
+ NETWORK_DIR=./network
+ NUM_NODES=3
+ GETH_BOOTNODE_PORT=30301
+ GETH_HTTP_PORT=8000
+ GETH_WS_PORT=8100
+ GETH_AUTH_RPC_PORT=8200
+ GETH_METRICS_PORT=8300
+ GETH_NETWORK_PORT=8400
+ PRYSM_BEACON_RPC_PORT=4000
+ PRYSM_BEACON_GRPC_GATEWAY_PORT=4100
+ PRYSM_BEACON_P2P_TCP_PORT=4200
+ PRYSM_BEACON_P2P_UDP_PORT=4300
+ PRYSM_BEACON_MONITORING_PORT=4400
+ PRYSM_VALIDATOR_RPC_PORT=7000
+ PRYSM_VALIDATOR_GRPC_GATEWAY_PORT=7100
+ PRYSM_VALIDATOR_MONITORING_PORT=7200
+ trap 'echo "Error on line $LINENO"; exit 1' ERR
+ trap cleanup SIGINT
+ rm -rf ./network
+ mkdir -p ./network
+ pkill geth
+ echo 'No existing geth processes'
No existing geth processes
+ pkill beacon-chain
pkill: killing pid 13619 failed: 명령을 허용하지 않음
+ echo 'No existing beacon-chain processes'
No existing beacon-chain processes
+ pkill validator
pkill: killing pid 13620 failed: 명령을 허용하지 않음
+ echo 'No existing validator processes'
No existing validator processes
+ pkill bootnode
+ echo 'No existing bootnode processes'
No existing bootnode processes
+ GETH_BINARY=./dependencies/go-ethereum_v1.13.12/build/bin/geth
+ GETH_BOOTNODE_BINARY=./dependencies/go-ethereum_v1.13.12/build/bin/bootnode
+ PRYSM_CTL_BINARY=./dependencies/prysm_v4.2.1/bazel-bin/cmd/prysmctl/prysmctl_/prysmctl
+ PRYSM_BEACON_BINARY=./dependencies/prysm_v4.2.1/bazel-bin/cmd/beacon-chain/beacon-chain_/beacon-chain
+ PRYSM_VALIDATOR_BINARY=./dependencies/prysm_v4.2.1/bazel-bin/cmd/validator/validator_/validator
+ mkdir -p ./network/bootnode
+ ./dependencies/go-ethereum_v1.13.12/build/bin/bootnode -genkey ./network/bootnode/nodekey
+ sleep 2
+ ./dependencies/go-ethereum_v1.13.12/build/bin/bootnode -nodekey ./network/bootnode/nodekey -addr=:30301 -verbosity=5
++ head -n 1 ./network/bootnode/bootnode.log
+ bootnode_enode='enode://f33a93b983627b2fb4f710bb8cc7c5bdfb1947db28ba4edefdee1b3dffdebbb8f3aeebace7932eba5bda67e17128fd21b599cd234f67d2250eb56b76c10282f5@127.0.0.1:0?discport=30301'
+ [[ enode://f33a93b983627b2fb4f710bb8cc7c5bdfb1947db28ba4edefdee1b3dffdebbb8f3aeebace7932eba5bda67e17128fd21b599cd234f67d2250eb56b76c10282f5@127.0.0.1:0?discport=30301 == enode* ]]
+ echo 'bootnode enode is: enode://f33a93b983627b2fb4f710bb8cc7c5bdfb1947db28ba4edefdee1b3dffdebbb8f3aeebace7932eba5bda67e17128fd21b599cd234f67d2250eb56b76c10282f5@127.0.0.1:0?discport=30301'
bootnode enode is: enode://f33a93b983627b2fb4f710bb8cc7c5bdfb1947db28ba4edefdee1b3dffdebbb8f3aeebace7932eba5bda67e17128fd21b599cd234f67d2250eb56b76c10282f5@127.0.0.1:0?discport=30301
+ ./dependencies/prysm_v4.2.1/bazel-bin/cmd/prysmctl/prysmctl_/prysmctl testnet generate-genesis --fork=deneb --num-validators=3 --chain-config-file=./config.yml --geth-genesis-json-in=./genesis.json --output-ssz=./network/genesis.ssz --geth-genesis-json-out=./network/genesis.json
INFO[0000] Specified a chain config file: ./config.yml   prefix=genesis
INFO[0000] No genesis time specified, defaulting to now()  prefix=genesis
INFO[0000] Delaying genesis 1716357948 by 0 seconds      prefix=genesis
INFO[0000] Genesis is now 1716357948                     prefix=genesis
INFO[0000] Setting fork geth times                       cancun=1716357948 prefix=genesis shanghai=1716357948
INFO[0000] Done writing genesis state to ./network/genesis.ssz  prefix=genesis
INFO[0000] Command completed                             prefix=genesis
+ PRYSM_BOOTSTRAP_NODE=
+ MIN_SYNC_PEERS=1
+ echo 1 is minimum number of synced peers required
1 is minimum number of synced peers required
+ (( i=0 ))
+ (( i<3 ))
+ NODE_DIR=./network/node-0
+ mkdir -p ./network/node-0/execution
+ mkdir -p ./network/node-0/consensus
+ mkdir -p ./network/node-0/logs
+ geth_pw_file=./network/node-0/geth_password.txt
+ echo ''
+ cp ./config.yml ./network/node-0/consensus/config.yml
+ cp ./network/genesis.ssz ./network/node-0/consensus/genesis.ssz
+ cp ./network/genesis.json ./network/node-0/execution/genesis.json
+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth account new --datadir ./network/node-0/execution --password ./network/node-0/geth_password.txt
INFO [05-22|15:05:48.958] Maximum peer count                       ETH=50 total=50

Your new key was generated

Public address of the key:   0xCf09d73a7E10367bCcE6756a219B6863e7cb6C19
Path of the secret key file: network/node-0/execution/keystore/UTC--2024-05-22T06-05-48.959364599Z--cf09d73a7e10367bcce6756a219b6863e7cb6c19

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!

+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth init --datadir=./network/node-0/execution ./network/node-0/execution/genesis.json
INFO [05-22|15:05:49.782] Maximum peer count                       ETH=50 total=50
INFO [05-22|15:05:49.797] Set global gas cap                       cap=50,000,000
INFO [05-22|15:05:49.797] Initializing the KZG library             backend=gokzg
INFO [05-22|15:05:49.811] Defaulting to pebble as the backing database
INFO [05-22|15:05:49.811] Allocated cache and file handles         database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-0/execution/geth/chaindata cache=16.00MiB handles=16
INFO [05-22|15:05:49.879] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-0/execution/geth/chaindata/ancient/chain readonly=false
INFO [05-22|15:05:49.879] State schema set to default              scheme=path
ERROR[05-22|15:05:49.879] Zero trie root hash!
ERROR[05-22|15:05:49.879] Head block is not reachable
INFO [05-22|15:05:49.923] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-0/execution/geth/chaindata/ancient/state readonly=false
INFO [05-22|15:05:49.924] Writing custom genesis block
INFO [05-22|15:05:50.008] Successfully wrote genesis state         database=chaindata hash=51c23e..88ee49
INFO [05-22|15:05:50.008] Defaulting to pebble as the backing database
INFO [05-22|15:05:50.008] Allocated cache and file handles         database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-0/execution/geth/lightchaindata cache=16.00MiB handles=16
INFO [05-22|15:05:50.077] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-0/execution/geth/lightchaindata/ancient/chain readonly=false
INFO [05-22|15:05:50.078] State schema set to default              scheme=path
ERROR[05-22|15:05:50.078] Zero trie root hash!
ERROR[05-22|15:05:50.078] Head block is not reachable
INFO [05-22|15:05:50.123] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-0/execution/geth/lightchaindata/ancient/state readonly=false
INFO [05-22|15:05:50.123] Writing custom genesis block
INFO [05-22|15:05:50.209] Successfully wrote genesis state         database=lightchaindata hash=51c23e..88ee49
+ sleep 5
+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth --networkid=6832 --http --http.api=eth,net,web3 --http.addr=127.0.0.1 '--http.corsdomain=*' --http.port=8000 --port=8400 --metrics.port=8300 --ws --ws.api=eth,net,web3 --ws.addr=127.0.0.1 '--ws.origins=*' --ws.port=8100 '--authrpc.vhosts=*' --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=./network/node-0/execution/jwtsecret --authrpc.port=8200 --datadir=./network/node-0/execution --password=./network/node-0/geth_password.txt '--bootnodes=enode://f33a93b983627b2fb4f710bb8cc7c5bdfb1947db28ba4edefdee1b3dffdebbb8f3aeebace7932eba5bda67e17128fd21b599cd234f67d2250eb56b76c10282f5@127.0.0.1:0?discport=30301' --identity=node-0 --maxpendpeers=3 --verbosity=3 --syncmode=full
+ [[ -z '' ]]
+ sleep 5
+ ./dependencies/prysm_v4.2.1/bazel-bin/cmd/beacon-chain/beacon-chain_/beacon-chain --datadir=./network/node-0/consensus/beacondata --min-sync-peers=1 --genesis-state=./network/node-0/consensus/genesis.ssz --bootstrap-node= --interop-eth1data-votes --chain-config-file=./network/node-0/consensus/config.yml --contract-deployment-block=0 --chain-id=6832 --rpc-host=127.0.0.1 --rpc-port=4000 --grpc-gateway-host=127.0.0.1 --grpc-gateway-port=4100 --execution-endpoint=http://localhost:8200 --accept-terms-of-use --jwt-secret=./network/node-0/execution/jwtsecret --suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 --minimum-peers-per-subnet=0 --p2p-tcp-port=4200 --p2p-udp-port=4300 --monitoring-port=4400 --verbosity=info --slasher --enable-debug-rpc-endpoints
+ ./dependencies/prysm_v4.2.1/bazel-bin/cmd/validator/validator_/validator --beacon-rpc-provider=localhost:4000 --datadir=./network/node-0/consensus/validatordata --accept-terms-of-use --interop-num-validators=1 --interop-start-index=0 --rpc-port=7000 --grpc-gateway-port=7100 --monitoring-port=7200 --graffiti=node-0 --chain-config-file=./network/node-0/consensus/config.yml
++ curl -s localhost:4100/eth/v1/node/identity
++ jq -r .data.enr
+ PRYSM_BOOTSTRAP_NODE=enr:-MK4QGb67Pxh49z-gxnEcUCHAYC41vx63ckboPOXBWdNtbCQPW5EvF4XJsMsDlV4V3kho9ULWGnbWAQDak8hCO56KiSGAY9cjsXbh2F0dG5ldHOIMAAAAAAAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQMw3zHjOlJka0prSkgvJ9f3kJqDAkWdf3rvl0fE1xVmhohzeW5jbmV0cwCDdGNwghBog3VkcIIQzA
+ [[ enr:-MK4QGb67Pxh49z-gxnEcUCHAYC41vx63ckboPOXBWdNtbCQPW5EvF4XJsMsDlV4V3kho9ULWGnbWAQDak8hCO56KiSGAY9cjsXbh2F0dG5ldHOIMAAAAAAAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQMw3zHjOlJka0prSkgvJ9f3kJqDAkWdf3rvl0fE1xVmhohzeW5jbmV0cwCDdGNwghBog3VkcIIQzA == enr* ]]
+ echo 'PRYSM_BOOTSTRAP_NODE is valid: enr:-MK4QGb67Pxh49z-gxnEcUCHAYC41vx63ckboPOXBWdNtbCQPW5EvF4XJsMsDlV4V3kho9ULWGnbWAQDak8hCO56KiSGAY9cjsXbh2F0dG5ldHOIMAAAAAAAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQMw3zHjOlJka0prSkgvJ9f3kJqDAkWdf3rvl0fE1xVmhohzeW5jbmV0cwCDdGNwghBog3VkcIIQzA'
PRYSM_BOOTSTRAP_NODE is valid: enr:-MK4QGb67Pxh49z-gxnEcUCHAYC41vx63ckboPOXBWdNtbCQPW5EvF4XJsMsDlV4V3kho9ULWGnbWAQDak8hCO56KiSGAY9cjsXbh2F0dG5ldHOIMAAAAAAAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQMw3zHjOlJka0prSkgvJ9f3kJqDAkWdf3rvl0fE1xVmhohzeW5jbmV0cwCDdGNwghBog3VkcIIQzA
+ (( i++  ))
+ (( i<3 ))
+ NODE_DIR=./network/node-1
+ mkdir -p ./network/node-1/execution
+ mkdir -p ./network/node-1/consensus
+ mkdir -p ./network/node-1/logs
+ geth_pw_file=./network/node-1/geth_password.txt
+ echo ''
+ cp ./config.yml ./network/node-1/consensus/config.yml
+ cp ./network/genesis.ssz ./network/node-1/consensus/genesis.ssz
+ cp ./network/genesis.json ./network/node-1/execution/genesis.json
+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth account new --datadir ./network/node-1/execution --password ./network/node-1/geth_password.txt
INFO [05-22|15:06:00.398] Maximum peer count                       ETH=50 total=50

Your new key was generated

Public address of the key:   0x435CF61c6f4beE6A6dA75f1fDD215eb46C480BbD
Path of the secret key file: network/node-1/execution/keystore/UTC--2024-05-22T06-06-00.399708926Z--435cf61c6f4bee6a6da75f1fdd215eb46c480bbd

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!

+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth init --datadir=./network/node-1/execution ./network/node-1/execution/genesis.json
INFO [05-22|15:06:01.233] Maximum peer count                       ETH=50 total=50
INFO [05-22|15:06:01.237] Set global gas cap                       cap=50,000,000
INFO [05-22|15:06:01.237] Initializing the KZG library             backend=gokzg
INFO [05-22|15:06:01.253] Defaulting to pebble as the backing database
INFO [05-22|15:06:01.253] Allocated cache and file handles         database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-1/execution/geth/chaindata cache=16.00MiB handles=16
INFO [05-22|15:06:01.321] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-1/execution/geth/chaindata/ancient/chain readonly=false
INFO [05-22|15:06:01.321] State schema set to default              scheme=path
ERROR[05-22|15:06:01.322] Zero trie root hash!
ERROR[05-22|15:06:01.322] Head block is not reachable
INFO [05-22|15:06:01.368] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-1/execution/geth/chaindata/ancient/state readonly=false
INFO [05-22|15:06:01.368] Writing custom genesis block
INFO [05-22|15:06:01.457] Successfully wrote genesis state         database=chaindata hash=51c23e..88ee49
INFO [05-22|15:06:01.457] Defaulting to pebble as the backing database
INFO [05-22|15:06:01.457] Allocated cache and file handles         database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-1/execution/geth/lightchaindata cache=16.00MiB handles=16
INFO [05-22|15:06:01.526] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-1/execution/geth/lightchaindata/ancient/chain readonly=false
INFO [05-22|15:06:01.526] State schema set to default              scheme=path
ERROR[05-22|15:06:01.527] Zero trie root hash!
ERROR[05-22|15:06:01.527] Head block is not reachable
INFO [05-22|15:06:01.570] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-1/execution/geth/lightchaindata/ancient/state readonly=false
INFO [05-22|15:06:01.570] Writing custom genesis block
INFO [05-22|15:06:01.657] Successfully wrote genesis state         database=lightchaindata hash=51c23e..88ee49
+ sleep 5
+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth --networkid=6832 --http --http.api=eth,net,web3 --http.addr=127.0.0.1 '--http.corsdomain=*' --http.port=8001 --port=8401 --metrics.port=8301 --ws --ws.api=eth,net,web3 --ws.addr=127.0.0.1 '--ws.origins=*' --ws.port=8101 '--authrpc.vhosts=*' --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=./network/node-1/execution/jwtsecret --authrpc.port=8201 --datadir=./network/node-1/execution --password=./network/node-1/geth_password.txt '--bootnodes=enode://f33a93b983627b2fb4f710bb8cc7c5bdfb1947db28ba4edefdee1b3dffdebbb8f3aeebace7932eba5bda67e17128fd21b599cd234f67d2250eb56b76c10282f5@127.0.0.1:0?discport=30301' --identity=node-1 --maxpendpeers=3 --verbosity=3 --syncmode=full
+ [[ -z enr:-MK4QGb67Pxh49z-gxnEcUCHAYC41vx63ckboPOXBWdNtbCQPW5EvF4XJsMsDlV4V3kho9ULWGnbWAQDak8hCO56KiSGAY9cjsXbh2F0dG5ldHOIMAAAAAAAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQMw3zHjOlJka0prSkgvJ9f3kJqDAkWdf3rvl0fE1xVmhohzeW5jbmV0cwCDdGNwghBog3VkcIIQzA ]]
+ (( i++  ))
+ (( i<3 ))
+ NODE_DIR=./network/node-2
+ mkdir -p ./network/node-2/execution
+ ./dependencies/prysm_v4.2.1/bazel-bin/cmd/beacon-chain/beacon-chain_/beacon-chain --datadir=./network/node-1/consensus/beacondata --min-sync-peers=1 --genesis-state=./network/node-1/consensus/genesis.ssz --bootstrap-node=enr:-MK4QGb67Pxh49z-gxnEcUCHAYC41vx63ckboPOXBWdNtbCQPW5EvF4XJsMsDlV4V3kho9ULWGnbWAQDak8hCO56KiSGAY9cjsXbh2F0dG5ldHOIMAAAAAAAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQMw3zHjOlJka0prSkgvJ9f3kJqDAkWdf3rvl0fE1xVmhohzeW5jbmV0cwCDdGNwghBog3VkcIIQzA --interop-eth1data-votes --chain-config-file=./network/node-1/consensus/config.yml --contract-deployment-block=0 --chain-id=6832 --rpc-host=127.0.0.1 --rpc-port=4001 --grpc-gateway-host=127.0.0.1 --grpc-gateway-port=4101 --execution-endpoint=http://localhost:8201 --accept-terms-of-use --jwt-secret=./network/node-1/execution/jwtsecret --suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 --minimum-peers-per-subnet=0 --p2p-tcp-port=4201 --p2p-udp-port=4301 --monitoring-port=4401 --verbosity=info --slasher --enable-debug-rpc-endpoints
+ ./dependencies/prysm_v4.2.1/bazel-bin/cmd/validator/validator_/validator --beacon-rpc-provider=localhost:4001 --datadir=./network/node-1/consensus/validatordata --accept-terms-of-use --interop-num-validators=1 --interop-start-index=1 --rpc-port=7001 --grpc-gateway-port=7101 --monitoring-port=7201 --graffiti=node-1 --chain-config-file=./network/node-1/consensus/config.yml
+ mkdir -p ./network/node-2/consensus
+ mkdir -p ./network/node-2/logs
+ geth_pw_file=./network/node-2/geth_password.txt
+ echo ''
+ cp ./config.yml ./network/node-2/consensus/config.yml
+ cp ./network/genesis.ssz ./network/node-2/consensus/genesis.ssz
+ cp ./network/genesis.json ./network/node-2/execution/genesis.json
+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth account new --datadir ./network/node-2/execution --password ./network/node-2/geth_password.txt
INFO [05-22|15:06:06.813] Maximum peer count                       ETH=50 total=50

Your new key was generated

Public address of the key:   0x9472974323761c30E2f1635815844F817d0879DD
Path of the secret key file: network/node-2/execution/keystore/UTC--2024-05-22T06-06-06.814279211Z--9472974323761c30e2f1635815844f817d0879dd

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!

+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth init --datadir=./network/node-2/execution ./network/node-2/execution/genesis.json
INFO [05-22|15:06:07.721] Maximum peer count                       ETH=50 total=50
INFO [05-22|15:06:07.724] Set global gas cap                       cap=50,000,000
INFO [05-22|15:06:07.724] Initializing the KZG library             backend=gokzg
INFO [05-22|15:06:07.738] Defaulting to pebble as the backing database
INFO [05-22|15:06:07.738] Allocated cache and file handles         database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-2/execution/geth/chaindata cache=16.00MiB handles=16
INFO [05-22|15:06:07.799] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-2/execution/geth/chaindata/ancient/chain readonly=false
INFO [05-22|15:06:07.800] State schema set to default              scheme=path
ERROR[05-22|15:06:07.800] Zero trie root hash!
ERROR[05-22|15:06:07.800] Head block is not reachable
INFO [05-22|15:06:07.839] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-2/execution/geth/chaindata/ancient/state readonly=false
INFO [05-22|15:06:07.839] Writing custom genesis block
INFO [05-22|15:06:07.925] Successfully wrote genesis state         database=chaindata hash=51c23e..88ee49
INFO [05-22|15:06:07.925] Defaulting to pebble as the backing database
INFO [05-22|15:06:07.925] Allocated cache and file handles         database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-2/execution/geth/lightchaindata cache=16.00MiB handles=16
INFO [05-22|15:06:07.991] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-2/execution/geth/lightchaindata/ancient/chain readonly=false
INFO [05-22|15:06:07.991] State schema set to default              scheme=path
ERROR[05-22|15:06:07.991] Zero trie root hash!
ERROR[05-22|15:06:07.991] Head block is not reachable
INFO [05-22|15:06:08.030] Opened ancient database                  database=/home/whsoo8232/my-blockchain/testnet-backup/network/node-2/execution/geth/lightchaindata/ancient/state readonly=false
INFO [05-22|15:06:08.030] Writing custom genesis block
INFO [05-22|15:06:08.108] Successfully wrote genesis state         database=lightchaindata hash=51c23e..88ee49
+ sleep 5
+ ./dependencies/go-ethereum_v1.13.12/build/bin/geth --networkid=6832 --http --http.api=eth,net,web3 --http.addr=127.0.0.1 '--http.corsdomain=*' --http.port=8002 --port=8402 --metrics.port=8302 --ws --ws.api=eth,net,web3 --ws.addr=127.0.0.1 '--ws.origins=*' --ws.port=8102 '--authrpc.vhosts=*' --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=./network/node-2/execution/jwtsecret --authrpc.port=8202 --datadir=./network/node-2/execution --password=./network/node-2/geth_password.txt '--bootnodes=enode://f33a93b983627b2fb4f710bb8cc7c5bdfb1947db28ba4edefdee1b3dffdebbb8f3aeebace7932eba5bda67e17128fd21b599cd234f67d2250eb56b76c10282f5@127.0.0.1:0?discport=30301' --identity=node-2 --maxpendpeers=3 --verbosity=3 --syncmode=full
+ [[ -z enr:-MK4QGb67Pxh49z-gxnEcUCHAYC41vx63ckboPOXBWdNtbCQPW5EvF4XJsMsDlV4V3kho9ULWGnbWAQDak8hCO56KiSGAY9cjsXbh2F0dG5ldHOIMAAAAAAAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQMw3zHjOlJka0prSkgvJ9f3kJqDAkWdf3rvl0fE1xVmhohzeW5jbmV0cwCDdGNwghBog3VkcIIQzA ]]
+ (( i++  ))
+ (( i<3 ))
+ ./dependencies/prysm_v4.2.1/bazel-bin/cmd/validator/validator_/validator --beacon-rpc-provider=localhost:4002 --datadir=./network/node-2/consensus/validatordata --accept-terms-of-use --interop-num-validators=1 --interop-start-index=2 --rpc-port=7002 --grpc-gateway-port=7102 --monitoring-port=7202 --graffiti=node-2 --chain-config-file=./network/node-2/consensus/config.yml
+ ./dependencies/prysm_v4.2.1/bazel-bin/cmd/beacon-chain/beacon-chain_/beacon-chain --datadir=./network/node-2/consensus/beacondata --min-sync-peers=1 --genesis-state=./network/node-2/consensus/genesis.ssz --bootstrap-node=enr:-MK4QGb67Pxh49z-gxnEcUCHAYC41vx63ckboPOXBWdNtbCQPW5EvF4XJsMsDlV4V3kho9ULWGnbWAQDak8hCO56KiSGAY9cjsXbh2F0dG5ldHOIMAAAAAAAAACEZXRoMpB-Ysp0IAAAk___________gmlkgnY0gmlwhKweATuJc2VjcDI1NmsxoQMw3zHjOlJka0prSkgvJ9f3kJqDAkWdf3rvl0fE1xVmhohzeW5jbmV0cwCDdGNwghBog3VkcIIQzA --interop-eth1data-votes --chain-config-file=./network/node-2/consensus/config.yml --contract-deployment-block=0 --chain-id=6832 --rpc-host=127.0.0.1 --rpc-port=4002 --grpc-gateway-host=127.0.0.1 --grpc-gateway-port=4102 --execution-endpoint=http://localhost:8202 --accept-terms-of-use --jwt-secret=./network/node-2/execution/jwtsecret --suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 --minimum-peers-per-subnet=0 --p2p-tcp-port=4202 --p2p-udp-port=4302 --monitoring-port=4402 --verbosity=info --slasher --enable-debug-rpc-endpoints
+ tail -f ./network/node-0/logs/geth.log ./network/node-1/logs/geth.log ./network/node-2/logs/geth.log
==> ./network/node-0/logs/geth.log <==
INFO [05-22|15:05:50.661] New local node record                    seq=1,716,357,950,657 id=ef5579f050a7ce61 ip=127.0.0.1 udp=8400 tcp=8400
INFO [05-22|15:05:50.661] Started P2P networking                   self=enode://7626966126e46d51ab70ec8d24582334d1543b65d88feca7c0fc34e1cb628d72f8b64f6b2ff74f8d32ae6c5dfdd4fd5f686587133bc3ef10451ea06625a77fc3@127.0.0.1:8400
INFO [05-22|15:05:50.661] IPC endpoint opened                      url=/home/whsoo8232/my-blockchain/testnet-backup/network/node-0/execution/geth.ipc
INFO [05-22|15:05:50.662] Generated JWT secret                     path=network/node-0/execution/jwtsecret
INFO [05-22|15:05:50.662] HTTP server started                      endpoint=127.0.0.1:8000 auth=false prefix= cors=* vhosts=localhost
INFO [05-22|15:05:50.662] WebSocket enabled                        url=ws://127.0.0.1:8100
INFO [05-22|15:05:50.662] WebSocket enabled                        url=ws://127.0.0.1:8200
INFO [05-22|15:05:50.662] HTTP server started                      endpoint=127.0.0.1:8200 auth=true  prefix= cors=localhost vhosts=*
INFO [05-22|15:06:00.677] Looking for peers                        peercount=0 tried=0 static=0
INFO [05-22|15:06:10.690] Looking for peers                        peercount=2 tried=0 static=0

==> ./network/node-1/logs/geth.log <==
INFO [05-22|15:06:02.086] Starting peer-to-peer node               instance=Geth/node-1/v1.14.0-unstable-9dcf8aae-20240410/linux-amd64/go1.21.0
INFO [05-22|15:06:02.107] New local node record                    seq=1,716,357,962,106 id=94d1080cb09bfbec ip=127.0.0.1 udp=8401 tcp=8401
INFO [05-22|15:06:02.108] Started P2P networking                   self=enode://2fbb2015c3693c7a532a7a013f913204e80fe52410f76aa6627342e77dafd89eb656830a2cfb2d73557a0474fd5782d3afe6d73897e22404219e4cbe86d50af1@127.0.0.1:8401
INFO [05-22|15:06:02.110] IPC endpoint opened                      url=/home/whsoo8232/my-blockchain/testnet-backup/network/node-1/execution/geth.ipc
INFO [05-22|15:06:02.110] Generated JWT secret                     path=network/node-1/execution/jwtsecret
INFO [05-22|15:06:02.110] HTTP server started                      endpoint=127.0.0.1:8001 auth=false prefix= cors=* vhosts=localhost
INFO [05-22|15:06:02.110] WebSocket enabled                        url=ws://127.0.0.1:8101
INFO [05-22|15:06:02.110] WebSocket enabled                        url=ws://127.0.0.1:8201
INFO [05-22|15:06:02.110] HTTP server started                      endpoint=127.0.0.1:8201 auth=true  prefix= cors=localhost vhosts=*
INFO [05-22|15:06:12.127] Looking for peers                        peercount=2 tried=1 static=0

==> ./network/node-2/logs/geth.log <==
WARN [05-22|15:06:08.472] Engine API enabled                       protocol=eth
INFO [05-22|15:06:08.473] Starting peer-to-peer node               instance=Geth/node-2/v1.14.0-unstable-9dcf8aae-20240410/linux-amd64/go1.21.0
INFO [05-22|15:06:08.487] New local node record                    seq=1,716,357,968,487 id=887c0f4394a4635d ip=127.0.0.1 udp=8402 tcp=8402
INFO [05-22|15:06:08.487] Started P2P networking                   self=enode://40f5109825bdbe20e0068ed0cb5741d17bee6a4d764730efdb49671f104238444fabc66ac1b860b2db28d86457a22d3fa971a9ff67c7c196966ea3515591be85@127.0.0.1:8402
INFO [05-22|15:06:08.488] IPC endpoint opened                      url=/home/whsoo8232/my-blockchain/testnet-backup/network/node-2/execution/geth.ipc
INFO [05-22|15:06:08.488] Generated JWT secret                     path=network/node-2/execution/jwtsecret
INFO [05-22|15:06:08.488] HTTP server started                      endpoint=127.0.0.1:8002 auth=false prefix= cors=* vhosts=localhost
INFO [05-22|15:06:08.488] WebSocket enabled                        url=ws://127.0.0.1:8102
INFO [05-22|15:06:08.488] WebSocket enabled                        url=ws://127.0.0.1:8202
INFO [05-22|15:06:08.488] HTTP server started                      endpoint=127.0.0.1:8202 auth=true  prefix= cors=localhost vhosts=*
INFO [05-22|15:06:18.501] Looking for peers                        peercount=2 tried=2 static=0

==> ./network/node-0/logs/geth.log <==
INFO [05-22|15:06:20.703] Looking for peers                        peercount=2 tried=0 static=0

==> ./network/node-1/logs/geth.log <==
INFO [05-22|15:06:22.142] Looking for peers                        peercount=2 tried=0 static=0

==> ./network/node-2/logs/geth.log <==
INFO [05-22|15:06:24.067] Starting work on payload                 id=0x03c2e987a1ab9787
INFO [05-22|15:06:24.067] Updated payload                          id=0x03c2e987a1ab9787 number=1 hash=99a8e7..c422d3 txs=0 withdrawals=0 gas=0 fees=0 root=bba0e4..b7d240 elapsed="71.214µs"
INFO [05-22|15:06:24.067] Stopping work on payload                 id=0x03c2e987a1ab9787 reason=delivery
INFO [05-22|15:06:24.087] Imported new potential chain segment     number=1 hash=99a8e7..c422d3 blocks=1 txs=0 mgas=0.000 elapsed=3.409ms    mgasps=0.000 triedirty=0.00B

==> ./network/node-1/logs/geth.log <==
INFO [05-22|15:06:24.091] Imported new potential chain segment     number=1 hash=99a8e7..c422d3 blocks=1 txs=0 mgas=0.000 elapsed=3.634ms  mgasps=0.000 triedirty=0.00B

==> ./network/node-2/logs/geth.log <==
INFO [05-22|15:06:24.106] Chain head was updated                   number=1 hash=99a8e7..c422d3 root=bba0e4..b7d240 elapsed=5.309203ms
ERROR[05-22|15:06:24.106] Nil finalized block cannot evict old blobs

==> ./network/node-1/logs/geth.log <==
INFO [05-22|15:06:24.109] Chain head was updated                   number=1 hash=99a8e7..c422d3 root=bba0e4..b7d240 elapsed=5.552209ms
ERROR[05-22|15:06:24.109] Nil finalized block cannot evict old blobs

==> ./network/node-2/logs/geth.log <==
INFO [05-22|15:06:24.112] Indexed transactions                     blocks=2 txs=0 tail=0 elapsed=6.105ms
INFO [05-22|15:06:24.117] Starting work on payload                 id=0x03918a71f983f585
INFO [05-22|15:06:24.117] Updated payload                          id=0x03918a71f983f585 number=2 hash=5ad4c7..fd3cdc txs=0 withdrawals=0 gas=0 fees=0 root=bba0e4..b7d240 elapsed="50.052µs"

==> ./network/node-1/logs/geth.log <==
INFO [05-22|15:06:24.117] Indexed transactions                     blocks=2 txs=0 tail=0 elapsed=8.218ms

==> ./network/node-0/logs/geth.log <==
WARN [05-22|15:06:25.641] Post-merge network, but no beacon client seen. Please launch one to follow the chain!

==> ./network/node-2/logs/geth.log <==
INFO [05-22|15:06:28.516] Looking for peers                        peercount=2 tried=0 static=0
