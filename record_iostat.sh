#!/bin/bash - 

source conf.sh

set -o nounset     # Treat unset variables as an error
trap "pkill -SIGKILL -P $$; kill -SIGKILL -- -$$" SIGINT SIGTERM SIGKILL SIGQUIT EXIT

HELP_TXT="Usage: `basename $0`"$'\n'

echo "Watching: ${WATCH_DISKS[*]}"

iostat -xt $IOSTAT_INTERVAL -p ${WATCH_DISKS[*]} > $DATA_DIR/raw_data.txt &
IOSTAT_PID=$!
wait $IOSTAT_PID
