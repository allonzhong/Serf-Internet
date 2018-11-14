#!/bin/bash
# Programname: incre-backup.sh 
# Revision:     1.0
# Description:  this script is used for incremental backup the SVN Subversion
# Author:       allonzhong
# Date:         2018.10.25
#
#####################################reseved days##################################
Maxdays=30
#####################################all name of the project#######################################
BaseDir=`find /data/{document,wwwroot} -maxdepth 1 -path /data/wwwroot/waimai.zftcloud.com -prune -o -type d -print`
#####################################where to backup？###########################################
Incre_BkDir=/bkdata/svn_backup/incre_svnbak
#####################################when do you start backup your project#####################################
Time=`date '+%F-%H-%M-%S'`
#   date +%Y-%m-%d-%T
#####################################the log record which project ,and which revison you backuped#####################
Icre_BkLog=/bkdir/svn_backup/svnlogs/incre_bksvn.log
######################################last time you full backup the project revison##################################
if [ ! -d ${Incre_BkDir} ]; then 
	 mkdir -pv ${Incre_BkDir} &> /dev/null
	 echo -e "\033[32m create the ${Incre_BkDir} successfully \033[0m"
else
	 echo -e "\033[33m the directory ${BakSubdir} is exist. \033[0m"
fi
[ ! -f ${Incre_BkLog} ] && touch ${Incre_BkLog} &> /dev/null
#exec	1> ${BakLog}
#exec	2>&1
set -x 
#  delete the old backupfile
#find ${BakFir} -maxdepth 1 -type f -mtime +$(expr ${Maxdays} -1) -exec echo "delete {}" \; -exec rm -f "{}" \;
#  full backup all the revision
find ${Incre_BkDir} -maxdepth 1 -type f -mtime +${Maxdays} -exec echo "delete {}" \; -exec rm -f {} \;
for dir in ${BaseDir} 
	do
    	Project=${dir##*/}
##################################### the revision you full backup the project ######################################
	Fullbk_index=`find /bkdata/svn_backup/rev_indexs -name *${Project}* -exec tail -1 {} \;`
#####################################the revision you start to incremental backup the project#########################
	ToRev_index=`/bin/svnlook youngest ${dir}`
###################################### incre-backup dumpfiles ######################################################
	Incre_bkfile=${Incre_BkDir}/${Project}-${time}.dump
   	/bin/svnadmin dump ${dir} --revision ${Fullbk_index}:${ToRev_index} --incremental > ${Incre_bkfile}
		if [ $? -eq 0 ]; then
			Bktime=`date '+%Y-%m-%d-%T'`
			echo -e "===========${Bktime}========[${Project}]:${Fullbk_index}-${ToRev_index}--> incre-backup successful!!!!!============" >> ${Icre_BkLog}
		else
			echo "backup failed......"
		fi
#  compress the backupfile
#cd ${BakDir}
#/usr/bin/tar -zcvf ${Time}.tar.gz ${Time}/
#rm -rf ${BakSubdir}

# put the backupfile to the remote host.
#Host=120.78.197.194
#RBakdir=/data/incre_backup
#Password=
#port=22
#/bin/expect << EOF
#	set	timeout   10
#	spawn scp -P $port ${Incre_bkfile} root@${Host}:${RBakdir}
#	expect  {	
#		"yes/no" { send "yes\r"; exp_continue}
#		"password:"  { send "$Password\r"}
#	}
#	expect	eof
#EOF
done
