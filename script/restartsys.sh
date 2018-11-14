#!/bin/bash
# Decription update the physical memory, and need to reboot the machine
# Author: allon zhong
# Date: 2018.07.23
Date=`date '+%F-%H-%M-%S'`
BinPrm=/usr/sbin/init
LogFile=/var/log/boot_log_`date '+%F-%H-%M-%S'`.log
[ ! -e $LogFile ] && touch $LogFile &> /dev/null
if [ -f $BinPrm ]; then
	$BinPrm 6 && echo -e "restart the system in $Date" >> $LogFile
fi
