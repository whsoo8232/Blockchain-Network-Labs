#!/bin/bash

function usage() {
	echo "parameter error"
	echo "Usage] ${0} all"
	echo "Usage] ${0} geth"
	echo "Usage] ${0} beacon-chain"
	echo "Usage] ${0} validator"
	echo "Usage] ${0} bootnode"
}
function showdown_process() {
	REST=`pkill  ${1} || echo "No existing ${1} processes"`
	if [ "${REST}" == "" ]; then
		REST="${1} processes is shutdown"
	fi
	echo "${REST}"
}

if [ "${#}" == "1" -a "${1}" == "all" ]; then
	showdown_process geth
	showdown_process beacon-chain
	showdown_process validator
	showdown_process bootnode
elif [ "${#}" == "1" -a "${1}" == "geth" ]; then
	showdown_process geth
elif [ "${#}" == "1" -a "${1}" == "beacon-chain" ]; then
	showdown_process beacon-chain
elif [ "${#}" == "1" -a "${1}" == "validator" ]; then
	showdown_process validator
elif [ "${#}" == "1" -a "${1}" == "bootnode" ]; then
	showdown_process bootnode
else
	usage
fi
