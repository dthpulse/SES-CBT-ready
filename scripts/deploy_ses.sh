set -ex

source /root/.bashrc

monitors=($monitors)
osd_nodes=($osd_nodes)

systemctl restart salt-master

    sleep 60

salt \* saltutil.sync_all

sleep 15

ceph-salt config /ceph_cluster/minions add "*"
ceph-salt config /ceph_cluster/roles/cephadm add "*"
ceph-salt config /ceph_cluster/roles/admin add "$master"

ceph-salt config /ceph_cluster/roles/bootstrap set "${monitors[0]}"

for i in ${monitors[@]}
do
    ceph-salt config /ceph_cluster/roles/admin add "$i"
done

ceph-salt config /ssh generate
ceph-salt config /time_server/server_hostname set "$master"
ceph-salt config /time_server/external_servers add "ntp.suse.cz"
ceph-salt config /cephadm_bootstrap/ceph_image_path set "registry.suse.de/suse/sle-15-sp2/update/products/ses7/update/cr/containers/ses/7/ceph/ceph"
ceph-salt config ls

ceph-salt status

ceph-salt export > myconfig.json

ceph-salt apply --non-interactive

for node in ${osd_nodes[@]%%.*}
do
    ceph orch host add $node
done

cat << EOF > /root/cluster.yaml
service_type: mon
placement:
  host_pattern: '*'
---
service_type: mgr
placement:
  host_pattern: '*'
---
service_id: osds
service_type: osd
placement:
  host_pattern: '*'
data_devices:
  rotational: 1
db_devices:
  model: 'INTEL SSDPED1K375GA'
EOF

ceph orch apply -i /root/cluster.yaml

# wait until all OSDs are deployed
for i in ${osd_nodes[@]%%.*}
do
    while [ ! "$(ceph osd tree --format=json | jq -r '.nodes[] | .name, .status'  \
               | grep -v default \
               | sed 's/null//g' \
               | tr '\n' ' ' \
               | awk "/$i/ && /osd./ && ! /down/{print \$0}")" ] \
          || [  "$(ceph osd tree --format=json | jq -r '.stray[] | .status' | grep down)" ] 
    do
        sleep 60
    done

done

ceph config set global mon_allow_pool_delete true

ceph config set global mon_clock_drift_allowed 2.0

ceph config set mon public_network 10.100.96.0/19

ceph config set global cluster_network 192.168.88.10/24

ceph config set global osd_pool_default_pg_autoscale_mode off
