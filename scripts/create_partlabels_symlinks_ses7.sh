set -ex

rm -f /tmp/ceph.conf

doitman () {
 if [ ! -d /dev/disk/by-partlabel ]
 then
	 mkdir /dev/disk/by-partlabel
 fi
 cd /dev/disk/by-partlabel
 if [ -z "$num" ]
 then
  num=0
 else
  let num+=1
 fi
}

for line in `ls -d /var/lib/ceph/$(ceph fsid)/osd*`
do
 osd_id=${line##*.}
 #wal=`find $line -type l -name block.wal -exec readlink {} \;`
 db=`find $line -type l -name block.db -exec readlink {} \;`
 wal=$db
 block=`find $line -type l -name block -exec readlink {} \;`
 #data=`find $line -type l -name block -exec readlink {} \; | cut -d / -f 3 | while read line;do pvdisplay | grep -B 1 $line | head -1 | awk '{print $3}';done`
 data=$line
 doitman
 ln -s $data osd-device-${num}-data
 ln -s $block osd-device-${num}-block
 ln -s $db osd-device-${num}-db
 ln -s $wal osd-device-${num}-wal

 echo "[osd.$osd_id]" >> /tmp/ceph.conf
 if [ -z "`grep -wA 1 \"osd.$osd_id\" /tmp/ceph.conf | grep -v osd.$osd_id`" ]
 then
  echo "    host = `hostname -f`" >> /tmp/ceph.conf
 fi
 echo "    osd_data = /dev/disk/by-partlabel/osd-device-${num}-data" >> /tmp/ceph.conf
 echo "    bluestore_block_path = /dev/disk/by-partlabel/osd-device-${num}-block" >> /tmp/ceph.conf
 echo "    bluestore_block_db_path = /dev/disk/by-partlabel/osd-device-${num}-db" >> /tmp/ceph.conf
 echo "    bluestore_block_wal_path = /dev/disk/by-partlabel/osd-device-${num}-wal" >> /tmp/ceph.conf

done
unset num

exit 0
