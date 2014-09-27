#!/bin/bash

DATE=$(date '+%Y-%m-%d')
tar cvpfJ /root/www.diegominpin.com-${DATE}.tar.xz --directory /root/ --exclude /usr/share/nginx/html/gallery/resources/cache --exclude /root/www.diegominpin.com/gallery/resources/cache/ /usr/share/nginx/html/ /root/www.diegominpin.com/
if [ $? -eq 0 ]; then
	scp -P 2222 /root/www.diegominpin.com-${DATE}.tar.xz root@vhome.dataking.us:/media/sf_backups/
else
	echo "There was a problem with the backup."
fi
