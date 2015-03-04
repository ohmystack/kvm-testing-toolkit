#!/bin/bash - 

source conf.sh
source utils.sh

set -o nounset                              # Treat unset variables as an error

HELP_TXT="Usage: `basename $0` [ -y ]"$'\n'

while getopts ':y' OPT; do
  case $OPT in
    y)
      ALWAYS_YES=true;;
    ?)
      echo "${HELP_TXT}"
  esac
done

ALWAYS_YES=${ALWAYS_YES:-false}

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

logout_func ()
{
  echo "Start to logout."
  echo
  for i in "${vms[@]}" ; do
    echo "Clear VM screen for $i"
    virsh send-key $i KEY_ESC
    sleep 1
    virsh send-key $i KEY_ESC
  done

  echo "sleep 10s."
  sleep 10

  for i in "${vms[@]}" ; do
    echo "Start to logout $i"

    virsh send-key $i KEY_ESC
    sleep 0.3
    virsh send-key $i KEY_LEFTMETA
    sleep 0.3
    virsh send-key $i KEY_C
    virsh send-key $i KEY_M
    virsh send-key $i KEY_D
    sleep 0.3
    virsh send-key $i KEY_ENTER
    sleep 1
    virsh send-key $i KEY_S
    virsh send-key $i KEY_H
    virsh send-key $i KEY_U
    virsh send-key $i KEY_T
    virsh send-key $i KEY_D
    virsh send-key $i KEY_O
    virsh send-key $i KEY_W
    virsh send-key $i KEY_N
    virsh send-key $i KEY_SPACE
    virsh send-key $i KEY_SLASH
    virsh send-key $i KEY_L
    virsh send-key $i KEY_SPACE
    virsh send-key $i KEY_SLASH
    virsh send-key $i KEY_F
    virsh send-key $i KEY_ENTER
  done
}	# ----------  end of function logout_func  ----------

if [ "${ALWAYS_YES}" = true ]; then
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
