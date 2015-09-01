#!/bin/bash - 

source conf.sh

set -o nounset     # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` [raw_mem_data_file]"$'\n'

TIMESTAMP_FILE=${DATA_DIR}/mem_timestamp.txt
DATA_FILE=${DATA_DIR}/raw_mem_data.txt
OUTPUT_FILE=${DATA_DIR}/result-mem-$(date +%Y%m%d-%H%M%S).csv

LINES_DISTANCE=5
MEM_LINES_FROM=2

tmp_dir='/tmp/mem-testing'
mkdir -p $tmp_dir

# Insert a line ahead of timestamp
tmp_timestamp=$tmp_dir/timestamp.txt
echo ',' > $tmp_timestamp
cat $TIMESTAMP_FILE >> $tmp_timestamp

mem_description_line=1
sed -n -e "$mem_description_line p" $DATA_FILE | tr -s [:blank:] ',' > $tmp_dir/mem.txt
sed -n -e "${MEM_LINES_FROM}~${LINES_DISTANCE} p" $DATA_FILE | tr -s [:blank:] ',' >> $tmp_dir/mem.txt
paste_files="$tmp_dir/timestamp.txt $tmp_dir/mem.txt"

paste -d ',' $paste_files > $OUTPUT_FILE

rm -rf $tmp_dir

echo "Check out the result: $OUTPUT_FILE"
echo
