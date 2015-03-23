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

./record_iostat.sh &
RECORD_IOSTAT_PID=$!

wait $TEST_CASES_PID

kill $RECORD_IOSTAT_PID
pkill -P $RECORD_IOSTAT_PID

./analysis.sh
