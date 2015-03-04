#!/bin/bash - 

source conf.sh

set -o nounset                              # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` -n <vm_number> -b <base_vm_name> -o <original_disk> -d <to_disk_directory> [ -f -y ]"$'\n'"-f: full_clone; -y: always_yes"$'\n'

while getopts ':n:b:o:d:fy' OPT; do
  case $OPT in
    n)
      VM_COUNT="$OPTARG";;
    b)
      BASE_VM="$OPTARG";;
    o)
      BASE_DISK="$OPTARG";;
    d)
      DISK_DIR="$OPTARG";;
    f)
      FULL_CLONE=true;;
    y)
      ALWAYS_YES=true;;
    ?)
      echo "${HELP_TXT}"
  esac
done

if [ -z "${VM_COUNT+x}" ] || [ -z "${BASE_VM+x}" ] || [ -z "${BASE_DISK+x}" ] || [ -z "${DISK_DIR+x}"  ]; then
  echo "Error: Missing params..."
  echo "${HELP_TXT}"
  exit 1
fi

FULL_CLONE=${FULL_CLONE:-false}
ALWAYS_YES=${ALWAYS_YES:-false}

if [ ! -d ${DISK_DIR} ] ; then
  if [ "${ALWAYS_YES}" = true ] ; then
    mkdir -p ${DISK_DIR}
  else
    read -p "${DISK_DIR} not exits. Create it now? (y/n)" QUESTION
    echo

    if [[ "${QUESTION}" =~ ^[Yy]$ ]]; then
      mkdir -p ${DISK_DIR}
    else
      echo "Exit."
      echo "Please create ${DISK_DIR} by yourself before retry."
      exit 1
    fi
  fi
fi

check_file_exists ()
{
  disk_path=$1
  if [ -f ${disk_path} ] ; then
    echo "*************************************************************"
    echo "${disk_path}: File exists."
    echo "Please clear old VMs before recreate VMs with the same name."
    echo "*************************************************************"
    echo ""
    exit 1
  fi
}	# ----------  end of function check_file_exists  ----------

for n in $(seq 1 $VM_COUNT); do
  if [ "$FULL_CLONE" = true ] ; then
    vm_name=${BASE_VM}_base${n}
    disk_path="${DISK_DIR}/${vm_name}.qcow2"
    check_file_exists $disk_path
    cmd_clone="virt-clone --replace -o ${BASE_VM} -n ${vm_name} -f ${disk_path}"
  else
    vm_name=${BASE_VM}_${n}
    disk_path="${DISK_DIR}/${vm_name}.qcow2"
    check_file_exists $disk_path
    cmd_disk="qemu-img create -f qcow2 -b ${BASE_DISK} ${disk_path}"
    echo "${cmd_disk}"
    eval ${cmd_disk}
    cmd_clone="virt-clone --preserve-data --replace -o ${BASE_VM} -n ${vm_name} -f ${disk_path}"
  fi

  echo "${cmd_clone}"
  eval ${cmd_clone}
done
