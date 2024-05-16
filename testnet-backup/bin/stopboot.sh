#!/bin/bash

#pkill -INT bootnode || echo "No existing bootnode processes"
REST=`pkill  bootnode || echo "No existing bootnode processes"`
if [ "${REST}" == "" ]; then
	REST="bootnode processes is shutdown"
fi
echo "${REST}"
