#!/bin/bash

mkdir /root/scripts
vim /root/scripts/etcdbackup.sh

backup_path="/root/etcd-backups"
date=$(date +"%d-%b-%Y")
oldest_date=$(date -d "$date - 5 days" +"%d-%b-%Y")
date_time=$(date +"%d-%b-%Y-%H-%M")
cluster=$(hostname)
backup_path_remote="s3://bahriya-etcd-backups/$cluster"
tmp_dir="/root/tmp"

# Create clean directory
mkdir -p $backup_path/$date
rm -rf $tmp_dir
mkdir -p $tmp_dir
cd $tmp_dir

# Create Snapshot
export ETCDCTL_API=3
etcdctl snapshot save \
      --cacert /etc/kubernetes/pki/etcd/ca.crt \
      --cert /etc/kubernetes/pki/etcd/server.crt \
      --key /etc/kubernetes/pki/etcd/server.key \
      $tmp_dir/etcd-backup.db

# Compress the current directory
tar -czvf etcd-backup-$date_time.tar.gz etcd-backup.db
rm etcd-backup.db

# Remove oldest date from backup dir
rm -rf $backup_path/$oldest_date

# Copy the tar to the right location
cp etcd-backup-$date_time.tar.gz $backup_path/$date/

# Copy to Object Storage
s3cmd -v -r --delete-removed sync $backup_path/ $backup_path_remote/