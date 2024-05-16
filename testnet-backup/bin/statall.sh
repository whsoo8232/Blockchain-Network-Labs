#!/bin/bash

#ps -ef | grep bootnode | grep -v grep
#ps -ef | grep geth | grep -v grep
#ps -ef | grep beacon-chain | grep -v grep
#ps -ef | grep validator | grep -v grep
ps -ef | egrep "bootnode|geth|beacon-chain|validator" | grep -v grep
