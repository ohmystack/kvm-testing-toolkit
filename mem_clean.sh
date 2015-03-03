#!/bin/bash - 

set -o nounset     # Treat unset variables as an error

HELP_TXT="Usage: `basename $0`"$'\n'

service libvirt-bin restart
service qemu-kvm restart
sync && echo 3 | tee /proc/sys/vm/drop_caches
