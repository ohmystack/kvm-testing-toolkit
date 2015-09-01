#!/bin/bash - 

source conf.sh

set -o nounset     # Treat unset variables as an error
trap "pkill -SIGKILL -P $$; kill -SIGKILL -- -$$" SIGINT SIGTERM SIGKILL SIGQUIT EXIT

HELP_TXT="Usage: `basename $0`"$'\n'

timestamp_file=$DATA_DIR/mem_timestamp.txt
mem_raw_file=$DATA_DIR/raw_mem_data.txt

rm -f $timestamp_file
rm -f $mem_raw_file

while true; do
  date +%Y-%m-%d,%H:%M:%S >> $timestamp_file
  free -m -t >> $mem_raw_file
  sleep $FREE_INTERVAL
done
