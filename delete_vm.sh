#!/bin/bash - 

source conf.sh
source utils.sh

set -o nounset                              # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` -b <base_vm_name> -d <disk_directory> [ -y ]"$'\n'

while getopts ':b:d:y' OPT; do
  case $OPT in
    b)
      BASE_VM="$OPTARG";;
    d)
      DIST_DIR="$OPTARG";;
    y)
      ALWAYS_YES=true;;
    ?)
      echo "${HELP_TXT}"
  esac
done

ALWAYS_YES=${ALWAYS_YES:-false}

if [ -z "${BASE_VM+x}" ] || [ -z "${DISK_DIR+x}" ]; then
  echo "Error: Missing params..."
  echo "${HELP_TXT}"
  exit 1
fi

linked_vms=($(get_linked_vms))
base_vms=($(get_base_vms))

echo "Linked VMs:"
if [ ! ${#linked_vms[@]} -eq 0 ] ; then
  print_array "${linked_vms[@]}"
else
  echo "(no such vm)"
fi
echo
echo "Base VMs:"
if [ ! ${#base_vms[@]} -eq 0 ] ; then
  print_array "${base_vms[@]}"
else
  echo "(no such vm)"
fi
echo

delete_vm_func ()
{
  if [ $# -lt 1 ] ; then
    return
  fi
  for i in "$@" ; do
    echo "Deleting $i"
    virsh destroy $i
    virsh undefine $i
    rm ${DISK_DIR}/${i}.qcow2
  done
}	# ----------  end of function delete_func  ----------


delete_all_vms ()
{
  if [ ! ${#linked_vms[@]} -eq 0 ] ; then
    delete_vm_func "${linked_vms[@]}"
  fi
  if [ ! ${#base_vms[@]} -eq 0 ] ; then
    delete_vm_func "${base_vms[@]}"
  fi
}	# ----------  end of function delete_all_vms  ----------

if [ "${ALWAYS_YES}" = true ]; then
  delete_all_vms
else
  read -p "Delete these VMs? (y/n)" QUESTION
  echo
  if [[ "${QUESTION}" =~ ^[Yy]$ ]]; then
    delete_all_vms
  else
    exit 0
  fi
fi
