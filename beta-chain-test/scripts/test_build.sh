#!/bin/bash
. ./setting.sh

set -exu
set -o pipefail

./init.sh

./bootnode_create.sh

./generate_genesis.sh

NODE_NUM=0
./node_create.sh ${NODE_NUM}
./node_start.sh ${NODE_NUM}
sleep 3
./beacon_start.sh ${NODE_NUM}
sleep 5

NODE_NUM=1
./node_create.sh ${NODE_NUM}
./node_start.sh ${NODE_NUM}
sleep 3
./beacon_start.sh ${NODE_NUM}
sleep 5

NODE_NUM=2
./node_create.sh ${NODE_NUM}
./node_start.sh ${NODE_NUM}
sleep 3
./beacon_start.sh ${NODE_NUM}
sleep 5
