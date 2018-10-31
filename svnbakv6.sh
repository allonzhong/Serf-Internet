#!/bin/bash
# Programname:  svnbakup.sh
# Revision:     6.0
# Description:  this script is used for full backup the SVN Subversion
# Author:       allonzhong
# Date:         2018.10.10
#
Maxdays=7
#SvnDir_product=/data/document/product
####################################### All path of project need to be backuped #################################
BaseDir=`find /data/{wwwroot,document} -maxdepth 1 -path /data/wwwroot/waimai.zftcloud.com -prune -o -type d -print`
####################################### Where to backup in local host? #########################################
BakDir=/bkdata/svn_backup
Time=`date '+%F-%H-%M-%S'`
#Time=`date '+%d/%m/%Y-%H:%M:%S'`
####################################### The path you backup logs #############################################
Logdir=${BakDir}/svnlogs
Logfile=${Logdir}/fullbak_rev.log
Proc_log=${Logdir}/bkwork_print.log
BakSubdir=${BakDir}/${Time}
Rev_index=${BakDir}/rev_indexs
####################################### The path you store for backupfile #####################################
Bakfile=${BakDir}/bakdata
Bakerr_log=${Logdir}/svnbk-error.log
# export LANG=zh_CN.UTF-8
######################################## Create directory if it is not exist ###################################
Makdir() { 
	[ ! -d $1 ] && mkdir -pv $1 &> /dev/null && echo -e "\033[32m create the $1 successfully \033[0m"
}
Makdir ${Logdir}
Makdir ${BakSubdir}
Makdir ${Rev_index}
Makdir ${Bakfile}
######################################## Create file if it is not exist #####################################
[ ! -f ${Logfile} ] && touch ${Logfile} &> /dev/null
[ ! -f ${Proc_log} ] && touch ${Proc_log} &> /dev/null 
[ ! -f ${Bakerr_log} ] && touch ${Bakerr_log} &> /dev/null 
exec	1> ${Proc_log}
exec	2> ${Bakerr_log}
set -x 
###  delete the old backupfile
###  full backup all the revision

svn_backup() { 
####################################starting full backup revision##########################################
	if ! /bin/svnadmin hotcopy --clean-logs $1 ${BakSubdir} &> /dev/null; then
		#	sleep 3
			echo -e "\033[033m the directory is empty, or backup fail \033[0m"
			return 1
		else
#################################### check if the backupfile is useful#######################################
			echo -e "\033[32m backup successful...\033[0m"
			/bin/svnlook youngest ${BakSubdir} >> ${Index_file}  
				if [ $? -eq 0 ]; then
					FullBak_Rev=`/bin/svnlook youngest ${BakSubdir}` 
					echo "display ${FullBak_Rev}"
					echo -e "backup successful!!!"
				else 
					echo "backup failed......"
				fi
			return 0
		fi
}
for Dir in ${BaseDir} 
	do
	StartTime=`date '+%F-%H-%M-%S'`
	Project=${Dir##*/}
	Index_file=${Rev_index}/${Project}_index.txt
	[ ! -e ${Index_file} ] && touch ${Index_file} &> /dev/null  && echo -e "\033[32m create the ${Index_file} successfully \033[0m" 
	svn_backup ${Dir} 2> /dev/null
	if [ $? -eq 0 ]; then
                cd ${BakDir}
######################################## compress the backupfile. ############################################
                /bin/tar -zcvf ${Bakfile}/${Time}${Project}.tar.gz ${Time}/
                rm -rf ${BakSubdir}
		EndTime=`date '+%F-%H-%M-%S'`
		echo -e  "======[Beging]${StartTime}======[${Project}]:${FullBak_Rev}-->Full backup successful!!!======[Ending]${EndTime}======" >> ${Logfile}
        else
                echo -e "\033[32m the directory is wrong, or backup failed \033[0m "
		shift 
		continue
        fi

find ${Bakfile} -maxdepth 1 -type d -mtime +${Maxdays} -exec echo "delete {}" \; -exec rm -rf "{}" \;
#################################### Backup the backupfile to the remote host . ###################################.
Host=x.x.x.x
RBakdir=/data/rsvn_backup
Password='XXXXXXX'
port=22
/bin/expect << EOF
	set	timeout   1800
	spawn scp -P $port ${Bakfile}/${Time}${Project}.tar.gz root@${Host}:${RBakdir}
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
