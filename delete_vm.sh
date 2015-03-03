#!/bin/bash - 

source conf.sh

set -o nounset                              # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` -b <base_vm_name> -d <disk_directory> [ -y ]"$'\n'

while getopts ':b:d:y' OPT; do
  case $OPT in
    b)
      BASE_VM="$OPTARG";;
    d)
      DIST_DIR="$OPTARG";;
    y)
      ALWAYS_YES=1;;
    ?)
      echo "${HELP_TXT}"
  esac
done

if [ -z "${BASE_VM+x}" ] || [ -z "${DISK_DIR+x}" ]; then
  echo "Error: Missing params..."
  echo "${HELP_TXT}"
  exit 1
fi

cmd_get_vms="virsh list --all | sed '1d; \$d' | awk '\$2 ~ /^${BASE_VM}_[0-9]+\$/ {print \$2}'"

vms=`eval ${cmd_get_vms}`

echo "${vms}"
echo

delete_func ()
{
  echo "${vms}" | xargs -t -I '{}' virsh destroy '{}'
  echo "${vms}" | xargs -t -I '{}' virsh undefine '{}'
  echo "${vms}" | xargs -t -I '{}' rm "${DISK_DIR}/"'{}'".qcow2"
}	# ----------  end of function delete_func  ----------

if [[ "${ALWAYS_YES}" = 1 ]]; then
  delete_func
else
  read -p "Delete these VMs? (y/n)" QUESTION
  echo
  if [[ "${QUESTION}" =~ ^[Yy]$ ]]; then
    delete_func
  else
    exit 0
  fi
fi
