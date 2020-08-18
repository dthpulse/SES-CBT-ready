set -ex

source /home/cbt/.bashrc

osd_nodes=($osd_nodes)

cat /etc/ceph/ceph.conf > /tmp/ceph.conf

for node in ${osd_nodes[*]}; do
    ssh $node "cat /tmp/ceph.conf" 2>/dev/null >> /tmp/ceph.conf
done

cp /tmp/ceph.conf /opt/cbt/ceph.conf
