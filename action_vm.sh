#!/bin/bash - 

source conf.sh
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
      ALWAYS_YES=1;;
    ?)
      echo "${HELP_TXT}"
  esac
done

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

cmd_get_vms="virsh list --all | sed '1d; \$d' | awk '\$2 ~ /^${BASE_VM}_[0-9]+\$/ {print \$2}'"

vms=`eval ${cmd_get_vms}`

echo "${vms}"
echo

action_func ()
{
  vms_list=(`echo "${vms}" | xargs -I '{}' echo '{}'`)
  for ix in ${!vms_list[*]}; do
    cmd_start="virsh ${ACTION_NAME} ${vms_list[$ix]}"
    echo "${cmd_start}"
    eval ${cmd_start}
    sleep "${SLEEP_TIME}"
  done
}	# ----------  end of function action_func  ----------

if [[ "${ALWAYS_YES}" = 1 ]]; then
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
