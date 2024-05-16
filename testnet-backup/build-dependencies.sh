#!/bin/bash

# NOTE: THIS SCRIPT WAS TESTED WITH GOLANG 1.20 installed

set -exu
set -o pipefail

# Check if go is installed
if ! command -v go &> /dev/null; then
    echo "Error: go is not installed. Please install Go first."
    exit 1
fi

# Check if bazel is installed (see https://docs.prylabs.network/docs/install/install-with-bazel#install-bazel-using-bazelisk)
if ! command -v bazel &> /dev/null; then
    echo "Error: bazel is not installed. Please install bazel first. See https://docs.prylabs.network/docs/install/install-with-bazel#install-bazel-using-bazelisk"
    exit 1
fi

go version

# Check fo version is greater than 1.20
MIN_GO_VERSION="1.20"  # adjust this to your requirements
GO_VERSION=$(go version | awk '{print $3}' | tr -d "go")
if [[ $(echo "$MIN_GO_VERSION $GO_VERSION" | tr " " "\n" | sort -V | head -n 1) != "$MIN_GO_VERSION" ]]; then
    echo "Error: Go version $GO_VERSION is installed, but version $MIN_GO_VERSION or higher is required."
    exit 1
fi

# comment out start
#PRYSM_DIR=./dependencies/prysm
#GETH_DIR=./dependencies/go-ethereum
# comment out end

# new command start
PRYSM_DIR=./dependencies/prysm_v4.2.1
GETH_DIR=./dependencies/go-ethereum_v1.13.12

if [ ! -d ${PRYSM_DIR} ]; then
    mkdir -p ${PRYSM_DIR}
    git clone https://github.com/prysmaticlabs/prysm ./dependencies/prysm_v4.2.1
fi
if [ ! -d ${GETH_DIR} ]; then
    mkdir -p ${GETH_DIR}
    git clone https://github.com/ethereum/go-ethereum ./dependencies/go-ethereum_v1.13.12
fi
# new command end

( cd $PRYSM_DIR && bazel build //cmd/beacon-chain:beacon-chain && bazel build //cmd/validator:validator && bazel build //cmd/prysmctl:prysmctl )

( cd $GETH_DIR && make all )
