#!/bin/bash - 

source conf.sh

set -o nounset                              # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` -n <vm_number> -b <base_vm_name> -o <original_disk> -d <to_disk_directory> [ -y ]"$'\n'

while getopts ':n:b:o:d:y' OPT; do
  case $OPT in
    n)
      VM_COUNT="$OPTARG";;
    b)
      BASE_VM="$OPTARG";;
    o)
      BASE_DISK="$OPTARG";;
    d)
      DISK_DIR="$OPTARG";;
    y)
      ALWAYS_YES=1;;
    ?)
      echo "${HELP_TXT}"
  esac
done

if [ -z "${VM_COUNT+x}" ] || [ -z "${BASE_VM+x}" ] || [ -z "${BASE_DISK+x}" ] || [ -z "${DISK_DIR+x}"  ]; then
  echo "Error: Missing params..."
  echo "${HELP_TXT}"
  exit 1
fi

if [ ! -d ${DISK_DIR} ] ; then
  if [[ "${ALWAYS_YES}" = 1 ]] ; then
    mkdir ${DISK_DIR}
  else
    read -p "${DISK_DIR} not exits. Create it now? (y/n)" QUESTION
    echo

    if [[ "${QUESTION}" =~ ^[Yy]$ ]]; then
      mkdir ${DISK_DIR}
    else
      echo "Exit."
      echo "Please create ${DISK_DIR} by yourself before retry."
      exit 1
    fi
  fi
fi

for n in $(seq 1 $VM_COUNT); do
  vm_name=${BASE_VM}_${n}
  disk_path="${DISK_DIR}/${vm_name}.qcow2"
  if [ -f ${disk_path} ] ; then
    echo "${disk_path}: File exists."
    echo "Please clear old VMs before recreate VMs with the same name."
    echo ""
    exit 1
  fi

  cmd_disk="qemu-img create -f qcow2 -b ${BASE_DISK} ${disk_path}"
  cmd_clone="virt-clone --preserve-data --replace -o ${BASE_VM} -n ${vm_name} -f ${disk_path}"

  echo "${cmd_disk}"
  eval ${cmd_disk}
  echo "${cmd_clone}"
  eval ${cmd_clone}

done
