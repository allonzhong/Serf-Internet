#!/bin/bash
# Programname:  svnbakup.sh
# Revision:     1.0
# Description:  this script is used for full backup the SVN Subversion
# Author:       allonzhong
# Date:         2018.10.10
#
Maxdays=4
#SvnDir_product=/data/document/product
#SvnDir_java=/data/wwwroot/java
#SvnDir_fron=/data/wwwroot/frontpage
#SvnDir_many=/data/wwwroot/many.zftcloud.com
#SvnDir_test=/data/wwwroot/many.zftcloud.com_test
#SvnDir_php=/data/wwwroot/php
#SvnDir_platform=/data/wwwroot/platform.zftcloud.com
#SvnDir_waimai=/data/wwwroot/waimai.zftcloud.com
#SvnDir_webapp=/data/wwwroot/webapp
BaseDir=`find /data/wwwroot -maxdepth 1 -path /data/wwwroot/waimai.zftcloud.com -prune -o -type d -print`
BakDir=/bkdata/svn_backup
Time=`date '+%F-%H-%M-%S'`
BakLog=${BakDir}/${Time}.log
BakSubdir=${BakDir}/${Time}
# export LANG=zh_CN.UTF-8
[ ! -d $BakDir ] && mkdir -pv $BakDir &> /dev/null && echo -e "\033[32m create the $BakDir successfully \033[0m"
if [ ! -d ${BakSubdir} ]; then
	 mkdir -pv ${BakSubdir} &> /dev/null
else
	 echo -e "\033[33m the directory ${BakSubdir} is exist. \033[0m"
fi
[ ! -f ${BakLog} ] && touch ${BakLog} &> /dev/null
exec	1> ${BakLog}
exec	2>&1
set -x 
#  delete the old backupfile
#find ${BakFir} -maxdepth 1 -type f -mtime +$(expr ${Maxdays} -1) -exec echo "delete {}" \; -exec rm -f "{}" \;
#  full backup all the revision

svn_backup() { 
	if ! /bin/svnadmin hotcopy --clean-logs $1 ${BakSubdir} &> /dev/null; then
			sleep 3
			echo -e "\033[033m the directory is empty, or backup fail \033[0m"
			return 1
		else
#  check if the backupfile is useful 
			echo -e "\033[32m backup successful...\033[0m"
			/bin/svnlook youngest ${BakSubdir}
			return 0 
				if [ $? -ne 0 ]; then
			 		exit 2
				else
					EndTime=`date '+%F-%H-%M-%S'`
					echo -e "start backup the revision in $Time, and end in $EndTime" >>  ${BakLog}
				fi
		fi
}
for Dir in ${BaseDir} 
	do
	svn_backup ${Dir} 2> /dev/null
	if [ $? -eq 0 ]; then
		Project=${Dir##*/}
                cd ${BakDir}
                /bin/tar -zcvf ${Time}${Project}.tar.gz ${Time}/
                rm -rf ${BakSubdir}
        else
                echo -e "\033[32m the directory is wrong, or backup failed \033[0m "
		shift 
		continue
        fi

#  compress the backupfile
#cd ${BakDir}
#/usr/bin/tar -zcvf ${Time}.tar.gz ${Time}/
#rm -rf ${BakSubdir}
find ${BakDir} -maxdepth 1 -type d -mtime +${Maxdays} -exec echo "delete {}" \; -exec rm -rf "{}" \;

# put the backupfile to the remote host.
Host=120.78.197.194
RBakdir=/data/rsvn_backup
Password='vbl9ubyI6ImNuLXNoZW56a'
port=22
/bin/expect << EOF
	set	timeout   10
	spawn scp -P $port ${BakDir}/${Time}${Project}.tar.gz root@${Host}:${RBakdir}
	expect  {	
		"yes/no" { send "yes\r"; exp_continue}
		"password:"  { send "$Password\r"}
	}
	expect	eof
EOF
#sleep 10
done
#/bin/expect << EOF
#	set	timeout   10
#	spawn scp -P $port ${BakDir}/${Time}java.tar.gz root@${Host}:${RBakdir}
#	expect  {	
#		"yes/no" { send "yes\r"; exp_continue}
#		"password:"  { send "$Password\r"}
#	}
#	expect	eof
#EOF
	

#	set	RBakdir	  "/data/rsvn_backup"
#	set	Host	"120.79.147.187"
#	set	BakDir	"/data/svn_backup"
#	set	Time	"`date '+%F-%H-%M-%S'`"
#	set	Password	"zCgHOa7waKjii9lF"
#	set	port	"41000"
