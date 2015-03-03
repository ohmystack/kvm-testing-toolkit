export VM_COUNT=50
export BASE_VM="win7_sh_Hotel_2.4.0_base"
export BASE_DISK="/vdesktop/base/win7_sh_Hotel_2.4.0.qcow2"
export DISK_DIR="/vdesktop/instances"
export SLEEP_TIME=1

# Run configurations
export ALWAYS_YES=0
export SLEEP_AFTER_BUILD=60
export SLEEP_AFTER_START=600
export SLEEP_AFTER_LOGOUT=300
export SLEEP_AFTER_SHUTDOWN=180
export SLEEP_AFTER_DELETE=15

export IOSTAT_INTERVAL=5
export DATA_DIR='data'

if [ ! -d ${DATA_DIR} ] ; then
  mkdir -p $DATA_DIR
  chmod -R 777 $DATA_DIR
fi

# Data Analysis configurations
export WATCH_DISKS=('sdb')
