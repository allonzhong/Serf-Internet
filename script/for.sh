#!/bin/bash
#
var=`find /opt/svn -maxdepth 1 -type d`
for I in ${var}
do
#count=0
#countmax=`find /data/wwwroot -maxdepth 1 -type d`
	
#	svn_backup $I
#	Svn_Dir=${var##*/}
#
#	if [ $? -eq 0 ]; then
#		cd ${BakDir}
#		/bin/tar -zcvf ${Time}${Svn_Dir}.tar.gz ${Time}/
#		rm -rf ${BakSubdir}
#	else
#		echo -e "\033[32m the directory is wrong, or backup failed \033[0m "
#	fi
echo -e "\033[32m the directory is $I \033[0m"
done
