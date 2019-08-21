#!/bin/bash

log_date=$1

for i in `cat /opt/module/hadoop-2.7.2/etc/hadoop/slaves`
do
	ssh -t $i "sudo date -s $log_date"
done
