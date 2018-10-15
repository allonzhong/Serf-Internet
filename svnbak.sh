#!/bin/bash
# Programname:  svnbakup.sh
# Revision:     1.0
# Description:  this script is used for full backup the SVN Subversion
# Author:       allonzhong
# Date:         2018.10.10
#
Maxdays=7
SvnDir=/opt/svn/blue
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
/usr/bin/svnadmin hotcopy ${SvnDir} ${BakSubdir} &> /dev/null
#  check if the backupfile is useful 
/usr/bin/svnlook youngest ${BakSubdir}
if [ $? -ne 0 ]; then
	 exit 2
else
	EndTime=`date '+%F-%H-%M-%S'`
	echo -e "start backup the revision in $Time, and end in $EndTime" >>  ${BakLog}
fi
#  compress the backupfile
cd ${BakDir}
/usr/bin/tar -zcvf ${Time}.tar.gz ${Time}/
rm -rf ${BakSubdir}
find ${BakFir} -maxdepth 1 -type d -mtime +$(expr ${Maxdays} -1) -exec echo "delete {}" \; -exec rm -rf "{}" \;

# put the backupfile to the remote host.
Host=120.79.147.187
RBakdir=/data/rsvn_backup
Password='zCgHOa7waKjii9lF'
port=41000
/usr/bin/expect << EOF
	set	timeout   10
	spawn scp -P $port ${BakDir}/${Time}.tar.gz root@${Host}:${RBakdir}
	expect  {	
		"yes/no" { send "yes\r"; exp_continue}
		"password:"  { send "$Password\r"}
	}
	expect	eof
EOF
	

#	set	RBakdir	  "/data/rsvn_backup"
#	set	Host	"120.79.147.187"
#	set	BakDir	"/data/svn_backup"
#	set	Time	"`date '+%F-%H-%M-%S'`"
#	set	Password	"zCgHOa7waKjii9lF"
#	set	port	"41000"
