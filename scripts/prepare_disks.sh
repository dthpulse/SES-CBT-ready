#!/usr/bin/env bash

. /root/.bashrc

devices=($(lsblk -o KNAME | egrep -v 'sd.[[:digit:]]|^dm-|KNAME'))
os_device=$(df | grep /$ | awk '{print $1}' | cut -d / -f 3 | sed 's/.$//')
devices=(${devices[@]/$os_device})
for i in ${devices[@]};do
    /usr/bin/dd if=/dev/zero of=/dev/$i bs=1M count=10 conv=fsync
    /sbin/wipefs /dev/$i
done
