#!/bin/bash
# Programname:  svnbakup.sh
# Revision:     5.0
# Description:  this script is used for full backup the SVN Subversion
# Author:       allonzhong
# Date:         2018.10.10
#
Maxdays=7
#SvnDir_product=/data/document/product
#SvnDir_java=/data/wwwroot/java
#SvnDir_fron=/data/wwwroot/frontpage
#SvnDir_many=/data/wwwroot/many.zftcloud.com
#SvnDir_test=/data/wwwroot/many.zftcloud.com_test
#SvnDir_php=/data/wwwroot/php
#SvnDir_platform=/data/wwwroot/platform.zftcloud.com
#SvnDir_waimai=/data/wwwroot/waimai.zftcloud.com
#SvnDir_webapp=/data/wwwroot/webapp
BaseDir=`find /data/{wwwroot,document} -maxdepth 1 -path /data/wwwroot/waimai.zftcloud.com -prune -o -type d -print`
BakDir=/bkdata/svn_backup
Time=`date '+%F-%H-%M-%S'`
#Time=`date '+%d/%m/%Y-%H:%M:%S'`
Logdir=${BakDir}/svnlogs
Logfile=${Logdir}/fullbak_${Time}.log
Proc_log=${Logdir}/work_${Time}.log
BakSubdir=${BakDir}/${Time}
Rev_index=${BakDir}/rev_indexs
Bakfile=${BakDir}/bakdata
#FullBak_Num=${BakSubdir}/rev_index
# export LANG=zh_CN.UTF-8
Makdir() { 
	[ ! -d $1 ] && mkdir -pv $1 &> /dev/null && echo -e "\033[32m create the $1 successfully \033[0m"
}
Makdir ${Logdir}
Makdir ${BakSubdir}
Makdir ${Rev_index}
Makdir ${Bakfile}
[ ! -f ${Logfile} ] && touch ${Logfile} &> /dev/null
[ ! -f ${Proc_log} ] && touch ${Proc_log} &> /dev/null 
exec	1> ${Proc_log}
exec	2>&1
set -x 
#  delete the old backupfile
#find ${BakFir} -maxdepth 1 -type f -mtime +$(expr ${Maxdays} -1) -exec echo "delete {}" \; -exec rm -f "{}" \;
#  full backup all the revision

svn_backup() { 
	StartTime=`date '+%F-%H-%M-%S'`
	if ! /bin/svnadmin hotcopy --clean-logs $1 ${BakSubdir} &> /dev/null; then
		#	sleep 3
			echo -e "\033[033m the directory is empty, or backup fail \033[0m"
			return 1
		else
#  check if the backupfile is useful 
			echo -e "\033[32m backup successful...\033[0m"
			/bin/svnlook youngest ${BakSubdir} 1> ${Index_file} 2> /dev/null 
# >> ${FullBak_Num} 
#&& FullBak_Rev=`cat ${FullBak_Num}`
				if [ $? -ne 0 ]; then
					echo -e "start backup the revision in $Time, and end in $EndTime" 
				fi
			return 0
		fi
}
for Dir in ${BaseDir} 
	do
	Project=${Dir##*/}
	Index_file=${Rev_index}/${Project}_index.txt
	[ ! -e ${Index_file} ] && touch ${Index_file} &> /dev/null  && echo -e "\033[32m create the ${Index_file} successfully \033[0m" 
	svn_backup ${Dir} 2> /dev/null
	if [ $? -eq 0 ]; then
                cd ${BakDir}
                /bin/tar -zcvf ${Bakfile}/${Time}${Project}.tar.gz ${Time}/
                rm -rf ${BakSubdir}
		EndTime=`date '+%F-%H-%M-%S'`
		echo -e  ">>>>>[Beging]${StartTime}>>>>>[${Project}]:${FullBak_Rev}>>>Full backup successful!!!>>>[Ending]${EndTime}>>>>>" >> ${Logfile}
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
Host=X.X.X.X
RBakdir=/data/rsvn_backup
Password='XXXXXXX'
port=22
/bin/expect << EOF
	set	timeout   3600 
	spawn scp -P $port ${BakDir}/${Time}${Project}.tar.gz root@${Host}:${RBakdir}
	expect  {	
		"yes/no" { send "yes\r"; exp_continue}
		"password:"  { send "$Password\r"}
	}
	expect	eof
EOF
sleep 1
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
	


