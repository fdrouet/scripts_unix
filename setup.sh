#!/bin/bash
#

# Define te environnement
#LOG_LEVEL=TRACE

## Import of the utilities env
. utils/sys_env.sh

HOSTNAME=UNKNOWN
HOSTNAME_SHORT=UNKNOWN
if ${CYGWIN} ; then
	HOSTNAME=$(hostname)
	HOSTNAME_SHORT=$(hostname)
else
	HOSTNAME=$(hostname -f)
	HOSTNAME_SHORT=$(hostname -s)
fi


## Import of the utilities scripts
. utils/log_functions.sh
 
