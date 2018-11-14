#!/bin/bash
# Programname:  svnbakup.sh
# Revision:     1.0
# Description:  this script is used for full backup the SVN Subversion
# Author:       allonzhong
# Date:         2018.10.10
#
Maxdays=5
#SvnDir1=/opt/svn/blue
#SvnDir2=/opt/svn/wwwroot
BaseDir=`find /opt/svn -maxdepth 1 -type d`
BakDir=/data/svn_backup
Time=`date '+%F-%H-%M-%S'`
BakLog=${BakDir}/${Time}.log
BakSubdir=${BakDir}/${Time}
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
	/usr/bin/svnadmin hotcopy $1 ${BakSubdir} &> /dev/null
		if [ $? -ne 0 ]; then
			echo -e "\033[033m the directory is empty, backup fail \033[0m"
			continue
		else
#  check if the backupfile is useful 
			/usr/bin/svnlook youngest ${BakSubdir}
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
	#if [ ${Dir} == "/opt/svn" ];then
#	else	
	svn_backup ${Dir} &> /dev/null 
	Project=${Dir##*/}
	if [ $? -eq 0 ]; then
		cd ${BakDir}
		/bin/tar -zcvf ${Time}${Project}.tar.gz ${Time}/
		rm -rf ${BakSubdir}
	else
		echo -e "\033[32m the directory is wrong, or backup failed \033[0m "
	fi
		echo -e "\033[32m it is beginning backup the revision ${Dir} \033[0m" 

	
#svn_backup ${SvnDir1} 
#cd ${BakDir}
#/usr/bin/tar -zcvf ${Time}blue.tar.gz ${Time}/
#rm -rf ${BakSubdir}
#svn_backup ${SvnDir2} 
#cd ${BakDir}
#/usr/bin/tar -zcvf ${Time}wwwroot.tar.gz ${Time}/
#rm -rf ${BakSubdir}
##  compress the backupfile
#cd ${BakDir}
#/usr/bin/tar -zcvf ${Time}.tar.gz ${Time}/
#rm -rf ${BakSubdir}
find ${BakDir} -maxdepth 1 -type d -mtime +$(expr ${Maxdays} -1) -exec echo "delete {}" \; -exec rm -rf "{}" \;

# put the backupfile to the remote host.
Host=120.79.147.187
RBakdir=/data/rsvn_backup
Password='zCgHOa7waKjii9lF'
port=41000
/usr/bin/expect << EOF
	set	timeout   10
	spawn scp -P $port ${BakDir}/${Time}${Project}.tar.gz root@${Host}:${RBakdir}
	expect  {	
		"yes/no" { send "yes\r"; exp_continue}
		"password:"  { send "$Password\r"}
	}
	expect	eof
EOF
done

#/usr/bin/expect << EOF

#	set	RBakdir	  "/data/rsvn_backup"
#	set	Host	"120.79.147.187"
#	set	BakDir	"/data/svn_backup"
#	set	Time	"`date '+%F-%H-%M-%S'`"
#	set	Password	"zCgHOa7waKjii9lF"
#	set	port	"41000"
