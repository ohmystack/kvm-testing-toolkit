#!/bin/bash - 

source conf.sh
source utils.sh

set -o nounset     # Treat unset variables as an error
set -e             # Exit immediately if a command exits with a non-zero status
trap "pkill -SIGKILL -P $$; kill -SIGKILL -- -$$" SIGINT SIGTERM SIGKILL SIGQUIT EXIT

HELP_TXT="Usage: `basename $0`"$'\n'

log_path="${DATA_DIR}/timeline-$(date +%Y%m%d-%H%M%S).log"


if [ -f ${log_path} ] ; then
  rm "${log_path}"
fi

#-------------------------------------------------------------------------------
# Build VMs
#-------------------------------------------------------------------------------
echo "[`date`] Start to build VMs." >> "${log_path}"
if [ "$MULTI_BASE" = true ] ; then
  for i in $(seq 1 $BASE_COUNT) ; do
    _base_name=${BASE_VM}_base${i}
    _base_disk=${DISK_DIR}/${_base_name}.qcow2
    ./build_vm.sh -n $VM_COUNT -b ${_base_name} -o ${_base_disk} -y &
  done
else
  ./build_vm.sh -y &
fi
echo "===> [`date`] Sleep ${SLEEP_AFTER_BUILD}s after building VMs."
sleep "${SLEEP_AFTER_BUILD}"

clean_sys_cache

#-------------------------------------------------------------------------------
# Start VMs
#-------------------------------------------------------------------------------
echo "[`date`] Start VMs." >> "${log_path}"
./action_vm.sh -y start &
echo "===> [`date`] Sleep ${SLEEP_AFTER_START}s after starting VMs."
sleep "${SLEEP_AFTER_START}" &
wait $!

#-------------------------------------------------------------------------------
# Shutdown VMs
#-------------------------------------------------------------------------------
echo "[`date`] Start to shutdown VMs." >> "${log_path}"
./action_vm.sh -y shutdown &
echo "===> [`date`] Sleep ${SLEEP_AFTER_SHUTDOWN}s after shutting down VMs."
sleep "${SLEEP_AFTER_SHUTDOWN}" &
wait $!

#-------------------------------------------------------------------------------
# Delete VMs
#-------------------------------------------------------------------------------
echo "[`date`] Start to delete VMs." >> "${log_path}"
./delete_vm.sh -y &
echo "===> [`date`] Sleep ${SLEEP_AFTER_DELETE}s after deleting VMs."
sleep "${SLEEP_AFTER_DELETE}" &
wait $!

echo
echo "===> Done!"
echo "Test cases timeline: $log_path"
echo
