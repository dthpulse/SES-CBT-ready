#!/usr/bin/env bash

for node in ares artemis hera demeter;do
    devices=(sda sdb sdc sdd sde sdf sdg sdh nvme0n1)
    os_device=$(df | grep /$ | awk '{print $1}' | cut -d / -f 3 | sed 's/.$//')
    devices=(${devices[@]/$os_device})
    for i in ${devices[@]};do
        /usr/bin/dd if=/dev/zero of=/dev/$i bs=1M count=10 conv=fsync
        /sbin/wipefs -a /dev/$i
    done
done
