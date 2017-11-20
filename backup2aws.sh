#!/bin/bash

HOST=$1
TYPE=$2

DATE=$(date '+%Y-%m-%d-%H-%M-%S')

if [ "${TYPE}" = "root" ]; then
	tar cpfJ /tmp/${TYPE}_${HOST}_${DATE}.tar.xz --exclude-backups /root
	if [ $? -eq 0 ]; then
		aws s3 cp /tmp/${TYPE}_${HOST}_${DATE}.tar.xz s3://dk-website-backups/${HOST}/
		if [ $? -eq 0 ]; then
			rm -f /tmp/${TYPE}_${HOST}_${DATE}.tar.xz
		else
			echo "There was a problem with the transfer."
		fi
	else
		echo "There was a problem with the backup."
	fi
elif [ "${TYPE}" = "home" ]; then
	tar cpfJ /tmp/${TYPE}_${HOST}_${DATE}.tar.xz --exclude-backups --exclude="*.tar.gz" --exclude="*.tar.xz" --exclude="*.iso" /home
	if [ $? -eq 0 ]; then
		aws s3 cp /tmp/${TYPE}_${HOST}_${DATE}.tar.xz s3://dk-website-backups/${HOST}/
		if [ $? -eq 0 ]; then
			rm -vf /tmp/${TYPE}_${HOST}_${DATE}.tar.xz
		else
			echo "There was a problem with the transfer."
		fi
	else
		echo "There was a problem with the backup."
	fi
elif [ "${TYPE}" = "varetc" ]; then
	tar cpfJ /tmp/${TYPE}_${HOST}_${DATE}.tar.xz --exclude-backups --exclude-vcs --exclude="/var/tmp/*" --exclude="/var/run/*" --exclude="/var/cache/*" /etc /var
	if [ $? -eq 0 ]; then
		aws s3 cp /tmp/${TYPE}_${HOST}_${DATE}.tar.xz s3://dk-website-backups/${HOST}/
		if [ $? -eq 0 ]; then
			rm -vf /tmp/${TYPE}_${HOST}_${DATE}.tar.xz
		else
			echo "There was a problem with the transfer."
		fi
	else
		echo "There was a problem with the backup."
	fi
elif [ "${TYPE}" = "full" ]; then
	tar cpfJ /tmp/${TYPE}_${HOST}_${DATE}.tar.xz --exclude-backups --exclude-vcs --exclude ="/var/tmp/*" --exclude="/var/tmp" --exclude="/var/run/*" --exclude="/var/run" --exclude="/var/cache/*" --exclude="/var/cache" --exclude="/var/spool/*" --exclude="/var/spool" --exclude="/tmp/*" --exclude="/tmp" --exclude="/dev/*" --exclude="/dev" --exclude="/run/*" --exclude="/run" --exclude="/proc/*" --exclude="/proc" --exclude="/sys/*" --exclude="/sys" --exclude="*.tar.gz" --exclude="*.tar.xz" /
	if [ $? -eq 0 ]; then
		aws s3 cp /tmp/${TYPE}_${HOST}_${DATE}.tar.xz s3://dk-website-backups/${HOST}/
		if [ $? -eq 0 ]; then
			rm -vf /tmp/${TYPE}_${HOST}_${DATE}.tar.xz
		else
			echo "There was a problem with the transfer."
		fi
	else
		echo "There was a problem with the backup."
	fi
else
	echo "Unrecognized backup type."
	echo "Usage: ${0} hostname backup-type"
	exit 1
fi
