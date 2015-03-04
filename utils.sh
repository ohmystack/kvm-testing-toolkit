
get_all_vms ()
{
  echo $(virsh list --all | sed '1d; $d' | awk "\$2 ~ /^${BASE_VM}(_base[0-9]+)*_[0-9]+\$/ {print \$2}")
}	# ----------  end of function get_all_vms  ----------

get_linked_vms ()
{
  echo $(virsh list --all | sed '1d; $d' | awk "\$2 ~ /^${BASE_VM}(.)*_[0-9]+\$/ {print \$2}")
}	# ----------  end of function get_linked_vms  ----------

get_base_vms ()
{
  echo $(virsh list --all | sed '1d; $d' | awk "\$2 ~ /^${BASE_VM}_base[0-9]+\$/ {print \$2}")
}	# ----------  end of function get_base_vms  ----------

print_array ()
{
  #-------------------------------------------------------------------------------
  #  Usage: print_array "${your_array[@]}"
  #-------------------------------------------------------------------------------

  if [ $# -lt 1 ] ; then
    return
  fi
  ( IFS=$'\n'; printf '%s\n' "$@" )
}	# ----------  end of function print_array  ----------

clean_sys_cache ()
{
  service qemu-kvm restart
  service libvirt-bin restart
  sync
  echo 3 > /proc/sys/vm/drop_caches
  for i in "${WATCH_DISKS[@]}" ; do
    sg_sync -s /dev/$i
  done
}	# ----------  end of function clean_sys_cache  ----------
