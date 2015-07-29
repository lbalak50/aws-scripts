#!/bin/bash

DATE=$(date '+%Y-%m-%d')
tar cvpfJ /root/salt.dataking.us-${DATE}.tar.xz --directory /root/ /var/www/salt.dataking.us/
if [ $? -eq 0 ]; then
	#scp -P 2222 /root/www.dataking.us-${DATE}.tar.xz root@vhome.dataking.us:/media/sf_backups/
	aws s3 cp /root/salt.dataking.us-${DATE}.tar.xz s3://dk-website-backups/salt.dataking.us/
	if [ $? -eq 0 ]; then
		rm -f /root/salt.dataking.us-${DATE}.tar.xz
	else
		echo "There was a problem with the transfer."
	fi
else
	echo "There was a problem with the backup."
fi
