#!/bin/bash - 

source conf.sh

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
./build_vm.sh -y &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_BUILD}""s after building VMs."
sleep "${SLEEP_AFTER_BUILD}"

#-------------------------------------------------------------------------------
# Start VMs
#-------------------------------------------------------------------------------
echo "[`date`] Start VMs." >> "${log_path}"
./action_vm.sh -y start &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_START}""s after starting VMs."
sleep "${SLEEP_AFTER_START}"

#-------------------------------------------------------------------------------
# Logout
#-------------------------------------------------------------------------------
echo "[`date`] Start to logout." >> "${log_path}"
./logout_vm.sh -y &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_LOGOUT}""s after logout."
sleep "${SLEEP_AFTER_LOGOUT}"

#-------------------------------------------------------------------------------
# Shutdown VMs
#-------------------------------------------------------------------------------
echo "[`date`] Start to shutdown VMs." >> "${log_path}"
./action_vm.sh -y shutdown &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_SHUTDOWN}""s after shutting down VMs."
sleep "${SLEEP_AFTER_SHUTDOWN}"

#-------------------------------------------------------------------------------
# Start VMs - 2nd
#-------------------------------------------------------------------------------
echo "[`date`] Start VMs." >> "${log_path}"
./action_vm.sh -y start &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_START}""s after starting VMs."
sleep "${SLEEP_AFTER_START}"

#-------------------------------------------------------------------------------
# Shutdown VMs - 2nd
#-------------------------------------------------------------------------------
echo "[`date`] Start to shutdown VMs." >> "${log_path}"
./action_vm.sh -y shutdown &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_SHUTDOWN}""s after shutting down VMs."
sleep "${SLEEP_AFTER_SHUTDOWN}"

#-------------------------------------------------------------------------------
# Start VMs - 3rd
#-------------------------------------------------------------------------------
echo "[`date`] Start VMs." >> "${log_path}"
./action_vm.sh -y start &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_START}""s after starting VMs."
sleep "${SLEEP_AFTER_START}"

#-------------------------------------------------------------------------------
# Shutdown VMs - 3rd
#-------------------------------------------------------------------------------
echo "[`date`] Start to shutdown VMs." >> "${log_path}"
./action_vm.sh -y shutdown &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_SHUTDOWN}""s after shutting down VMs."
sleep "${SLEEP_AFTER_SHUTDOWN}"

#-------------------------------------------------------------------------------
# Delete VMs
#-------------------------------------------------------------------------------
echo "[`date`] Start to delete VMs." >> "${log_path}"
./delete_vm.sh -y &
echo "===> [`date`] Sleep ""${SLEEP_AFTER_DELETE}""s after deleting VMs."
sleep "${SLEEP_AFTER_DELETE}"

echo
echo "===> Done!"
echo "Test cases timeline: $log_path"
echo
