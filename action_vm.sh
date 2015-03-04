#!/bin/bash - 

source conf.sh
source utils.sh

VALID_ACTION_NAMES=("start" "shutdown" "destroy")

set -o nounset                              # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` -b <base_vm_name> -s <sleep_time> [ -y ] [action]"$'\n'"Actions: start | shutdown | destroy"$'\n'

while getopts ':b:s:y' OPT; do
  case $OPT in
    b)
      BASE_VM="$OPTARG";;
    s)
      SLEEP_TIME="$OPTARG";;
    y)
      ALWAYS_YES=true;;
    ?)
      echo "${HELP_TXT}"
  esac
done

ALWAYS_YES=${ALWAYS_YES:-false}

if [ -z "${BASE_VM+x}" ] || [ -z "${SLEEP_TIME+x}" ]; then
  echo "Error: Missing params..."
  echo "${HELP_TXT}"
  exit 1
fi

shift $(($OPTIND - 1))
ACTION_NAME=$1
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}
array_contains VALID_ACTION_NAMES "${ACTION_NAME}" && action_check=1 || action_check=0
if [ "${action_check}" = 0 ]; then
  echo "${ACTION_NAME} is an invalid action."
  echo
  exit 1
fi

vms=($(get_linked_vms))

echo "Linked VMs:"
if [ ! ${#vms[@]} -eq 0 ] ; then
  print_array "${vms[@]}"
else
  echo "(no such vm)"
  echo
  exit
fi
echo

action_func ()
{
  for i in "${vms[@]}" ; do
    cmd_start="virsh ${ACTION_NAME} $i"
    echo "${cmd_start}"
    eval ${cmd_start}
    sleep "${SLEEP_TIME}"
  done
}	# ----------  end of function action_func  ----------

if [ "${ALWAYS_YES}" = true ]; then
  action_func
else
  read -p "${ACTION_NAME} these VMs? (y/n)" QUESTION
  echo
  if [[ "${QUESTION}" =~ ^[Yy]$ ]]; then
    action_func
  else
    exit 0
  fi
fi
