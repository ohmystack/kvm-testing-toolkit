#!/bin/bash - 

source conf.sh

set -o nounset                              # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` [ -y ]"$'\n'

while getopts ':y' OPT; do
  case $OPT in
    y)
      ALWAYS_YES=1;;
    ?)
      echo "${HELP_TXT}"
  esac
done

cmd_get_vms="virsh list --all | sed '1d; \$d' | awk '\$2 ~ /^${BASE_VM}_[0-9]+\$/ {print \$2}'"

vms=`eval ${cmd_get_vms}`

echo "${vms}"
echo

logout_func ()
{
  echo "Start to logout."
  echo
  vms_list=(`echo "${vms}" | xargs -I '{}' echo '{}'`)
  for ix in ${!vms_list[*]}; do
    echo "Clear VM screen for ""${vms_list[$ix]}"
    virsh send-key "${vms_list[$ix]}" KEY_ESC
    sleep 1
    virsh send-key "${vms_list[$ix]}" KEY_ESC
  done

  echo "sleep 10s."
  sleep 10

  for ix in ${!vms_list[*]}; do
    echo "Start to logout ""${vms_list[$ix]}"

    virsh send-key "${vms_list[$ix]}" KEY_ESC
    sleep 0.3
    virsh send-key "${vms_list[$ix]}" KEY_LEFTMETA
    sleep 0.3
    virsh send-key "${vms_list[$ix]}" KEY_C
    virsh send-key "${vms_list[$ix]}" KEY_M
    virsh send-key "${vms_list[$ix]}" KEY_D
    sleep 0.3
    virsh send-key "${vms_list[$ix]}" KEY_ENTER
    sleep 1
    virsh send-key "${vms_list[$ix]}" KEY_S
    virsh send-key "${vms_list[$ix]}" KEY_H
    virsh send-key "${vms_list[$ix]}" KEY_U
    virsh send-key "${vms_list[$ix]}" KEY_T
    virsh send-key "${vms_list[$ix]}" KEY_D
    virsh send-key "${vms_list[$ix]}" KEY_O
    virsh send-key "${vms_list[$ix]}" KEY_W
    virsh send-key "${vms_list[$ix]}" KEY_N
    virsh send-key "${vms_list[$ix]}" KEY_SPACE
    virsh send-key "${vms_list[$ix]}" KEY_SLASH
    virsh send-key "${vms_list[$ix]}" KEY_L
    virsh send-key "${vms_list[$ix]}" KEY_SPACE
    virsh send-key "${vms_list[$ix]}" KEY_SLASH
    virsh send-key "${vms_list[$ix]}" KEY_F
    virsh send-key "${vms_list[$ix]}" KEY_ENTER
  done
}	# ----------  end of function logout_func  ----------

if [[ "${ALWAYS_YES}" = 1 ]]; then
  logout_func
else
  read -p "Logout the user in these VMs? (y/n)" QUESTION
  echo
  if [[ "${QUESTION}" =~ ^[Yy]$ ]]; then
    logout_func
  else
    exit 0
  fi
fi
