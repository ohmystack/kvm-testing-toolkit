#!/bin/bash - 

source conf.sh

set -o nounset     # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` [iostat_raw_data_file] [ device [,...] ]"$'\n'

DATA_FILE=${DATA_DIR}/raw_data.txt
OUTPUT_FILE=${DATA_DIR}/result-$(date +%Y%m%d-%H%M%S).csv
DISKS_COUNT=${#WATCH_DISKS[@]}

LINES_DISTANCE=$((6+$DISKS_COUNT))
TIMESTAMP_LINES_FROM=3
CPU_LINES_FROM=5
DISK_LINES_FROM=8

tmp_dir='/tmp/storage-testing'
mkdir -p $tmp_dir

echo ',,' > $tmp_dir/timestamp.txt    # Fake a title line
sed -n -e "${TIMESTAMP_LINES_FROM}~${LINES_DISTANCE} p" $DATA_FILE | tr -s [:blank:] ',' >> $tmp_dir/timestamp.txt
paste_files="$tmp_dir/timestamp.txt"

sed -n -e "$((CPU_LINES_FROM-1)) p" $DATA_FILE | tr -s [:blank:] ',' > $tmp_dir/cpu.txt
sed -n -e "${CPU_LINES_FROM}~${LINES_DISTANCE} p" $DATA_FILE | tr -s [:blank:] ',' >> $tmp_dir/cpu.txt
paste_files="$paste_files $tmp_dir/cpu.txt"

io_description_line=$(($DISK_LINES_FROM-1))
for i in "${WATCH_DISKS[@]}"; do
  sed -n -e "$io_description_line p" $DATA_FILE | tr -s [:blank:] ',' > $tmp_dir/${i}.txt
  sed -n -e "${DISK_LINES_FROM}~${LINES_DISTANCE} p" $DATA_FILE | tr -s [:blank:] ',' >> $tmp_dir/${i}.txt
  let $((DISK_LINES_FROM++))
  paste_files="$paste_files $tmp_dir/${i}.txt"
done

# Export but the 2nd line because the 1st record of iostat is always not correct
paste -d ',' $paste_files | sed '2d' > $OUTPUT_FILE 

rm -rf $tmp_dir

echo "Check out the result: $OUTPUT_FILE"
echo
