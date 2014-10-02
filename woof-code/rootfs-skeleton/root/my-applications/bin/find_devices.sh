#!/bin/ash
echo $0




#if test "$0" = "ash"; then max_depth=1; fi; cd /sys/block; if test "`cat /sys/block/md0/md/raid_disks`" = ""; then for i in `ls /sys/block | grep -v -E '^loop.*|^ram.*|^md.*'`; do read_link=`readlink $i | sed 's#\.\./#/sys/#'`; cd $read_link ; find_files=`find . -maxdepth $max_depth -type f`; for j in $find_files; do echo $j; cat $j; echo; done; cd /sys/block; done; fi
rm /tmp/find_devices.sh.txt
#if test "$0" = "ash"; then max_depth=1; fi
max_depth=1
cd /sys/block
if test "`cat /sys/block/md0/md/raid_disks`" = ""; then
# find block_devices
block_devices=`ls /sys/block | grep -v -E '^loop.*|^ram.*|^md.*'`
echo $block_devices
#for i in `ls /sys/block | grep -v -E '^loop.*|^ram.*|^md.*'`; do
for i in $block_devices; do
echo $i
read_link=`readlink $i | sed 's#\.\./#/sys/#'`
cd "$read_link"
echo "$read_link"
echo "$read_link" >> /tmp/find_devices.sh.txt
pwd

find_files=`find . -maxdepth $max_depth -type f`
for j in $find_files; do
echo $j >> /tmp/find_devices.sh.txt
echo $j 
cat $j
cat $j >> /tmp/find_devices.sh.txt
echo
echo >> /tmp/find_devices.sh.txt
done
cd /sys/block
done

#now find /device folder
max_depth=1
cd /sys/block
if test "`cat /sys/block/md0/md/raid_disks`" = ""; then
# find block_devices
block_devices=`ls /sys/block | grep -v -E '^loop.*|^ram.*|^md.*'`
echo $block_devices
#for i in `ls /sys/block | grep -v -E '^loop.*|^ram.*|^md.*'`; do
for i in $block_devices; do
echo $i
read_link=`readlink $i | sed 's#\.\./#/sys/#'`
cd "$read_link"/device
echo "$read_link"
echo "$read_link/device" >> /tmp/find_devices.sh.txt
pwd

find_files=`find . -maxdepth $max_depth -type f`
for j in $find_files; do
echo $j >> /tmp/find_devices.sh.txt
echo $j 
cat $j
cat $j >> /tmp/find_devices.sh.txt
echo
echo >> /tmp/find_devices.sh.txt
done
cd /sys/block
done
fi





#now find pattitions
max_depth=1
cd /sys/block

block_devices=`ls /sys/block | grep -v -E '^loop.*|^ram.*|^md.*'`
echo $block_devices

for i in $block_devices; do
echo $i
read_link=`readlink $i | sed 's#\.\./#/sys/#'`
cd "$read_link"
find_directorys=`find . -maxdepth $max_depth -type d | grep $i | sed 's#^\.##g'`
echo $find_directorys

for j in $find_directorys; do
cd $read_link$j
echo "now in " `pwd`
find_files=`find . -maxdepth $max_depth -type f`
for k in $find_files; do
echo $k >> /tmp/find_devices.sh.txt
echo $k 
cat $k
cat $k >> /tmp/find_devices.sh.txt
echo
echo >> /tmp/find_devices.sh.txt
#cd 
done
echo $j >> /tmp/find_devices.sh.txt
echo $j 
#cat $j
#cat $j >> /tmp/find_devices.sh.txt
echo
echo >> /tmp/find_devices.sh.txt
done
cd /sys/block
done









fi # first if


usb_files_func() {
	# find .* -name "*manu*"
./pci0000:00/0000:00:1f.2/usb1/manufacturer
./pci0000:00/0000:00:1f.2/usb1/1-1/manufacturer
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/manufacturer
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/manufacturer
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/manufacturer
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/manufacturer
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/manufacturer
./pci0000:00/0000:00:1f.4/usb2/manufacturer
../devices/pci0000:00/0000:00:1f.2/usb1/manufacturer
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/manufacturer
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/manufacturer
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/manufacturer
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/manufacturer
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/manufacturer
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/manufacturer
../devices/pci0000:00/0000:00:1f.4/usb2/manufacturer
# 

# find .* -name "*prod*"
./platform/pcspkr/input/input4/id/product
./platform/i8042/serio0/input/input0/id/product
./virtual/dmi/id/product_name
./virtual/dmi/id/product_version
./virtual/dmi/id/product_serial
./pci0000:00/0000:00:1f.2/usb1/product
./pci0000:00/0000:00:1f.2/usb1/1-1/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.0/input/input1/id/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.1/input/input2/id/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/1-1.3.1:1.0/input/input3/id/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/product
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/product
./pci0000:00/0000:00:1f.4/usb2/product
../devices/platform/pcspkr/input/input4/id/product
../devices/platform/i8042/serio0/input/input0/id/product
../devices/virtual/dmi/id/product_name
../devices/virtual/dmi/id/product_version
../devices/virtual/dmi/id/product_serial
../devices/pci0000:00/0000:00:1f.2/usb1/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.0/input/input1/id/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.1/input/input2/id/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/1-1.3.1:1.0/input/input3/id/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/product
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/product
../devices/pci0000:00/0000:00:1f.4/usb2/product
# 



# sys/devices/pci0000:00/0000:00:1f.1/host1/target1:0:0/1:0:0:0/vendor
#/sys/devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/manufacturer
#/sys/devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/manufacturer
#/sys/devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/manufacturer
 cd /sys/devices
 find .* -name "*usb*"
./pci0000:00/0000:00:1f.2/usb_host
./pci0000:00/0000:00:1f.2/usb_host/usb_host1
./pci0000:00/0000:00:1f.2/usb1
./pci0000:00/0000:00:1f.2/usb1/1-0:1.0/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-0:1.0/usb_endpoint/usbdev1.1_ep81
./pci0000:00/0000:00:1f.2/usb1/usb_device
./pci0000:00/0000:00:1f.2/usb1/usb_device/usbdev1.1
./pci0000:00/0000:00:1f.2/usb1/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/usb_endpoint/usbdev1.1_ep00
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1:1.0/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1:1.0/usb_endpoint/usbdev1.2_ep81
./pci0000:00/0000:00:1f.2/usb1/1-1/usb_device
./pci0000:00/0000:00:1f.2/usb1/1-1/usb_device/usbdev1.2
./pci0000:00/0000:00:1f.2/usb1/1-1/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/usb_endpoint/usbdev1.2_ep00
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.0/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.0/usb_endpoint/usbdev1.3_ep81
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.1/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.1/usb_endpoint/usbdev1.3_ep82
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/usb_device
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/usb_device/usbdev1.3
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/usb_endpoint/usbdev1.3_ep00
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3:1.0/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3:1.0/usb_endpoint/usbdev1.4_ep81
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/usb_device
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/usb_device/usbdev1.4
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/usb_endpoint/usbdev1.4_ep00
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/1-1.3.1:1.0/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/1-1.3.1:1.0/usb_endpoint/usbdev1.5_ep81
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/1-1.3.1:1.0/usb
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/usb_device
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/usb_device/usbdev1.5
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/usb_endpoint/usbdev1.5_ep00
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/usb_endpoint/usbdev1.7_ep81
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/usb_endpoint/usbdev1.7_ep82
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/usb_endpoint/usbdev1.7_ep01
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.1/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.1/usb_endpoint/usbdev1.7_ep83
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.1/usb_endpoint/usbdev1.7_ep02
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.2/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.2/usb_endpoint/usbdev1.7_ep84
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.2/usb_endpoint/usbdev1.7_ep03
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.3/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.3/usb_endpoint/usbdev1.7_ep85
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.3/usb_endpoint/usbdev1.7_ep04
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.4/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.4/usb_endpoint/usbdev1.7_ep05
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.4/usb_endpoint/usbdev1.7_ep86
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/usb_device
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/usb_device/usbdev1.7
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/usb_endpoint/usbdev1.7_ep00
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/1-1.3.4:1.0/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/1-1.3.4:1.0/usb_endpoint/usbdev1.13_ep81
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/1-1.3.4:1.0/usb_endpoint/usbdev1.13_ep02
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/usb_device
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/usb_device/usbdev1.13
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/usb_endpoint/usbdev1.13_ep00
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.0/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.0/usb_endpoint/usbdev1.14_ep01
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.0/usb_endpoint/usbdev1.14_ep82
3./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.0/usb_endpoint/usbdev1.14_ep83
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/usb_device
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/usb_device/usbdev1.14
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/usb_endpoint
./pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/usb_endpoint/usbdev1.14_ep00
./pci0000:00/0000:00:1f.4/usb_host
./pci0000:00/0000:00:1f.4/usb_host/usb_host2
./pci0000:00/0000:00:1f.4/usb2
./pci0000:00/0000:00:1f.4/usb2/2-0:1.0/usb_endpoint
./pci0000:00/0000:00:1f.4/usb2/2-0:1.0/usb_endpoint/usbdev2.1_ep81
./pci0000:00/0000:00:1f.4/usb2/usb_device
./pci0000:00/0000:00:1f.4/usb2/usb_device/usbdev2.1
./pci0000:00/0000:00:1f.4/usb2/usb_endpoint
./pci0000:00/0000:00:1f.4/usb2/usb_endpoint/usbdev2.1_ep00
../devices/pci0000:00/0000:00:1f.2/usb_host
../devices/pci0000:00/0000:00:1f.2/usb_host/usb_host1
../devices/pci0000:00/0000:00:1f.2/usb1
../devices/pci0000:00/0000:00:1f.2/usb1/1-0:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-0:1.0/usb_endpoint/usbdev1.1_ep81
../devices/pci0000:00/0000:00:1f.2/usb1/usb_device
../devices/pci0000:00/0000:00:1f.2/usb1/usb_device/usbdev1.1
../devices/pci0000:00/0000:00:1f.2/usb1/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/usb_endpoint/usbdev1.1_ep00
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1:1.0/usb_endpoint/usbdev1.2_ep81
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/usb_device
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/usb_device/usbdev1.2
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/usb_endpoint/usbdev1.2_ep00
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.0/usb_endpoint/usbdev1.3_ep81
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.1/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/1-1.1:1.1/usb_endpoint/usbdev1.3_ep82
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/usb_device
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/usb_device/usbdev1.3
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.1/usb_endpoint/usbdev1.3_ep00
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3:1.0/usb_endpoint/usbdev1.4_ep81
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/usb_device
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/usb_device/usbdev1.4
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/usb_endpoint/usbdev1.4_ep00
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/1-1.3.1:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/1-1.3.1:1.0/usb_endpoint/usbdev1.5_ep81
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/1-1.3.1:1.0/usb
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/usb_device
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/usb_device/usbdev1.5
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.1/usb_endpoint/usbdev1.5_ep00
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/usb_endpoint/usbdev1.7_ep81
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/usb_endpoint/usbdev1.7_ep82
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/usb_endpoint/usbdev1.7_ep01
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.1/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.1/usb_endpoint/usbdev1.7_ep83
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.1/usb_endpoint/usbdev1.7_ep02
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.2/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.2/usb_endpoint/usbdev1.7_ep84
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.2/usb_endpoint/usbdev1.7_ep03
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.3/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.3/usb_endpoint/usbdev1.7_ep85
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.3/usb_endpoint/usbdev1.7_ep04
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.4/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.4/usb_endpoint/usbdev1.7_ep05
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.4/usb_endpoint/usbdev1.7_ep86
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/usb_device
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/usb_device/usbdev1.7
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.2/usb_endpoint/usbdev1.7_ep00
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/1-1.3.4:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/1-1.3.4:1.0/usb_endpoint/usbdev1.13_ep81
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/1-1.3.4:1.0/usb_endpoint/usbdev1.13_ep02
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/usb_device
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/usb_device/usbdev1.13
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.4/usb_endpoint/usbdev1.13_ep00
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.0/usb_endpoint/usbdev1.14_ep01
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.0/usb_endpoint/usbdev1.14_ep82
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/1-1.3.3:1.0/usb_endpoint/usbdev1.14_ep83
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/usb_device
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/usb_device/usbdev1.14
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/usb_endpoint
../devices/pci0000:00/0000:00:1f.2/usb1/1-1/1-1.3/1-1.3.3/usb_endpoint/usbdev1.14_ep00
../devices/pci0000:00/0000:00:1f.4/usb_host
../devices/pci0000:00/0000:00:1f.4/usb_host/usb_host2
../devices/pci0000:00/0000:00:1f.4/usb2
../devices/pci0000:00/0000:00:1f.4/usb2/2-0:1.0/usb_endpoint
../devices/pci0000:00/0000:00:1f.4/usb2/2-0:1.0/usb_endpoint/usbdev2.1_ep81
../devices/pci0000:00/0000:00:1f.4/usb2/usb_device
../devices/pci0000:00/0000:00:1f.4/usb2/usb_device/usbdev2.1
../devices/pci0000:00/0000:00:1f.4/usb2/usb_endpoint
../devices/pci0000:00/0000:00:1f.4/usb2/usb_endpoint/usbdev2.1_ep00
../bus/hid/drivers/generic-usb
../bus/usb
../bus/usb/devices/usb1
../bus/usb/devices/usb2
../bus/usb/drivers/usbfs
../bus/usb/drivers/usb
../bus/usb/drivers/usb/usb1
../bus/usb/drivers/usb/usb2
../bus/usb/drivers/usbhid
../bus/usb/drivers/usbserial
../bus/usb/drivers/usbserial_generic
../bus/usb/drivers/usb-storage
../bus/usb-serial
../class/usb_host
../class/usb_host/usb_host1
../class/usb_host/usb_host2
../class/usb_device
../class/usb_device/usbdev1.1
../class/usb_device/usbdev2.1
../class/usb_device/usbdev1.2
../class/usb_device/usbdev1.3
../class/usb_device/usbdev1.4
../class/usb_device/usbdev1.5
../class/usb_device/usbdev1.7
../class/usb_device/usbdev1.13
../class/usb_device/usbdev1.14
../class/usb_endpoint
../class/usb_endpoint/usbdev1.1_ep81
../class/usb_endpoint/usbdev1.1_ep00
../class/usb_endpoint/usbdev2.1_ep81
../class/usb_endpoint/usbdev2.1_ep00
../class/usb_endpoint/usbdev1.2_ep81
../class/usb_endpoint/usbdev1.2_ep00
../class/usb_endpoint/usbdev1.3_ep81
../class/usb_endpoint/usbdev1.3_ep82
../class/usb_endpoint/usbdev1.3_ep00
../class/usb_endpoint/usbdev1.4_ep81
../class/usb_endpoint/usbdev1.4_ep00
../class/usb_endpoint/usbdev1.5_ep81
../class/usb_endpoint/usbdev1.5_ep00
../class/usb_endpoint/usbdev1.7_ep81
../class/usb_endpoint/usbdev1.7_ep82
../class/usb_endpoint/usbdev1.7_ep01
../class/usb_endpoint/usbdev1.7_ep83
../class/usb_endpoint/usbdev1.7_ep02
../class/usb_endpoint/usbdev1.7_ep84
../class/usb_endpoint/usbdev1.7_ep03
../class/usb_endpoint/usbdev1.7_ep85
../class/usb_endpoint/usbdev1.7_ep04
../class/usb_endpoint/usbdev1.7_ep05
../class/usb_endpoint/usbdev1.7_ep86
../class/usb_endpoint/usbdev1.7_ep00
../class/usb_endpoint/usbdev1.13_ep81
../class/usb_endpoint/usbdev1.13_ep02
../class/usb_endpoint/usbdev1.13_ep00
../class/usb_endpoint/usbdev1.14_ep01
../class/usb_endpoint/usbdev1.14_ep82
../class/usb_endpoint/usbdev1.14_ep83
../class/usb_endpoint/usbdev1.14_ep00
../class/usb
../module/usbcore
../module/usbcore/holders/usbhid
../module/usbcore/holders/usbserial
../module/usbcore/holders/usb_storage
../module/usbcore/parameters/nousb
../module/usbcore/parameters/usbfs_snoop
../module/usbcore/drivers/usb:usbfs
../module/usbcore/drivers/usb:hub
../module/usbcore/drivers/usb:usb
../module/usbhid
../module/usbhid/drivers/hid:generic-usb
../module/usbhid/drivers/usb:hiddev
../module/usbhid/drivers/usb:usbhid
../module/usbserial
../module/usbserial/drivers/usb:usbserial
../module/usbserial/drivers/usb-serial:generic
../module/usbserial/drivers/usb:usbserial_generic
../module/option/drivers/usb-serial:option1
../module/option/drivers/usb:option
../module/usb_storage
../module/usb_storage/drivers/usb:usb-storage
# 



}












