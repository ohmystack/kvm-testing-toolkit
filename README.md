# KVM Testing Toolkit

------

This toolkit can provide:

* Batch ** build / start / logout / shutdown / destroy / delete ** VMs, using libvirt commands
* Linked clone support, you can control the proportion of Base VMs and Linked VMs
* Record and analysis ** Disk / Memory ** data during the operations, and export to a CSV report

## Installation

```bash
git clone ...
cd kvm-testing-toolkit

# Edit conf.sh file
cp conf.sh.example conf.sh
```

## Configuration

Before you starting to use, you should prepare a BASE VM. All the VMs, include the future Base VMs, will be cloned from it.

This BASE VM should look like this, VM name doesn't matter:

```bash
$ sudo virsh list --all
 Id    Name                           State
----------------------------------------------------
 -     win7_base       shut off
```

Edit the `conf.sh` file, fill in correct info:

#### General Config

* `BASE_COUNT` : How many Base VMs will be created. But if `BASE_COUNT=1` , no more Base VMs will be created, because you already have one.
* `VM_COUNT` : How manay VMs will be link-cloned from ** every Base VM ** .
* `BASE_VM` : e.g. Here is the `win7_base` .
* `BASE_DISK` : The Base VM's disk file.
* `DISK_DIR` : Where you want the NEW VMs' disk files to place at.
* `SLEEP_TIME` : The interval (seconds) between building one VM and the next one.

#### Running detail Config

* `TEST_CASE_SCRIPT`: Which test script would you like to use. We already have 2 test case scripts, `test_cases.sh` and `test_cases_simple.sh` .
* `ALWAYS_YES` and `FULL_CLONE` : These only works when you run our commands seperately, not when you run test case scripts.
* `SLEEP_AFTER_xxx`: Control the time of each step.

```
                                                           
 Build > Start > Logout > Shutdown > Delete  +----> END    
   +       +       +         +         +            (Exit) 
   |       |       |         |         |                   
   |SLEEP_ |SLEEP_ |SLEEP_   |SLEEP_   |SLEEP_             
   |AFTER_ |AFTER_ |AFTER_   |AFTER_   |AFTER_             
   |BUILD  |START  |LOGOUT   |SHUTDOWN |DELETE             
   |       |       |         |         |                   
   |       |       |         |         |                   
   +       +       +         +         +                   
                                                           
```

#### Data file Config

* `DATA_DIR` : Where to store the raw data, timeline and CSV report.

#### Disk testing Config

* `IOSTAT_INTERVAL` : Record interval of `iostat` in seconds level
* `WATCH_DISKS` : A list of disks you want to watch, e.g. `('sda','sdb')`

#### Memory testing Config

* `FREE_INTERVAL` : Record interval of `free` in seconds level

## Usage

#### Run test case suite, and export an CSV report to DATA_DIR

```bash
# Run disk test
sudo ./run.sh

# Run memory test
sudo ./run_mem.sh
```

#### Run steps seperately

Build VMs

```bash
sudo ./build_vm.sh -n <vm_number> -b <base_vm_name> -o <original_disk> -d <to_disk_directory> [ -f -y ]
# e.g.
sudo ./build_vm.sh -n 5 -b win7_base -o /testvms/base/win7_base.qcow2 -d /testvms/instances
# Or if you have configured conf.sh, you can simply
sudo ./build_vm.sh
```

Start/shutdown/destroy VMs

```bash
sudo ./action_vm.sh start
sudo ./action_vm.sh shutdown
sudo ./action_vm.sh destroy

e.g.
$ sudo ./action_vm.sh start
Linked VMs:
win7_sh_Hotel_2.4.0_base_1
win7_sh_Hotel_2.4.0_base_2
win7_sh_Hotel_2.4.0_base_3
win7_sh_Hotel_2.4.0_base_4
win7_sh_Hotel_2.4.0_base_5

start these VMs? (y/n)
```

Delete VMs

```bash
sudo ./delete_vm.sh

e.g.
$ sudo ./delete_vm.sh
Linked VMs:
win7_sh_Hotel_2.4.0_base_1
win7_sh_Hotel_2.4.0_base_2
win7_sh_Hotel_2.4.0_base_3
win7_sh_Hotel_2.4.0_base_4
win7_sh_Hotel_2.4.0_base_5

Base VMs:
(no such vm)

Delete these VMs? (y/n)
```

## Data Analysis

The output files:

* `raw_data.txt` or `raw_mem_data.txt` : Saves all the raw stdout output.
* `timeline-20150323-141027.log` : Saves the start time of each step.
* `result-20150821-190139.csv` : The CSV report.

After you get the CSV reports, you can combin them and edit them in other softwares.

I have a sample result [here](samples/ssd-vs-hdd-result-v2.pdf), testing the disk performance, SSD vs HDD, in my environment.
