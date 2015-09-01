#!/bin/bash - 

source conf.sh

set -o nounset     # Treat unset variables as an error
trap "pkill -SIGTERM -P $$; kill -SIGKILL $$" SIGINT SIGTERM SIGKILL SIGQUIT EXIT

HELP_TXT="Usage: `basename $0`"$'\n'


#-------------------------------------------------------------------------------
# Prepare BASE VMs
#-------------------------------------------------------------------------------
if [ "$MULTI_BASE" = true ] ; then
  ./build_vm.sh -n $BASE_COUNT -f -y
fi

./$TEST_CASE_SCRIPT &
TEST_CASES_PID=$!

./record_mem.sh &
RECORD_MEM_PID=$!

wait $TEST_CASES_PID

kill -9 $RECORD_MEM_PID

./analysis_mem.sh
