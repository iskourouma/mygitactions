#!/bin/bash
#########################################################
#	Project: Child Care Conversion						#
#	Created by: Meet Patel								#
#	Created On: April 2021								#
#	Description: This script validates files coming 	#
#					from JFS.							#
#########################################################

log_file_name=conv_log_`date "+%y%m%d%H%M%S"`.txt
#base_dir=$INFA_HOME
base_dir=/u01/mw/inf/informatica105/pc105 
##base_dir=/home/vkancherla/base_dir
log_dir=$base_dir/server/infa_shared/conversion/log 
##log_dir=/home/vkancherla/base_dir/log

echo "This is the Informatica Home Directory: $base_dir" 2>&1 | tee $log_dir/$log_file_name

echo "This is the Log Directory: $log_dir" 2>&1 | tee -a $log_dir/$log_file_name

config_dir=$base_dir/server/infa_shared/conversion/scripts/config
#config_dir=/home/vkancherla/base_dir/scripts/config
echo "This is the config Directory: $config_dir" 2>&1 | tee -a $log_dir/$log_file_name

master_file=$config_dir/master_file_list.txt
echo "This is the master file: $config_dir" 2>&1 | tee -a $log_dir/$log_file_name

sftp_dir=/SFTP/inbound/persistent/MITS_SFTP/inbound 

##sftp_dir=/SFTP/inbound/persistent/CCCD_SFTP/quarantine/Inbound
##sftp_dir=/home/vkancherla/base_dir/inbound
echo "This is the SFTP Directory: $sftp_dir" 2>&1 | tee -a $log_dir/$log_file_name

sftp_archive_dir=$sftp_dir/archive
##sftp_archive_dir=/home/vkancherla/base_dir/inbound/archive
echo "This is the SFTP Archive Directory: $sftp_archive_dir" 2>&1 | tee -a $log_dir/$log_file_name


src_dir=$base_dir/server/infa_shared/mcee/SrcFiles 
##src_dir=/home/vkancherla/conversion/srcfiles
echo "This is the Source File Directory: $src_dir" 2>&1 | tee -a $log_dir/$log_file_name

#Audit File Name: this file will contain all the miss-match data
file_dtl=file_dtl_`date "+%y%m%d%H%M%S"`.txt

#audit file creation
echo "DESCRIPTION_OF_ERROR" | tee $log_dir/$file_dtl

chmod 777 $log_dir/$log_file_name

chmod 777 $log_dir/$file_dtl

#copy the files from SFTP Location to Informatica Source File Directory

###cp $sftp_dir/*.txt.processed $sftp_archive_dir/

#rename the files with extension
#for f in $src_dir/*.txt; do mv $f ${f%.txt}_`date "+%y%m%d%H%M%S"`.txt; done

#move the files from SFTP Location to SFTP Archive File Directory
###mv $sftp_dir/*.txt.processed $src_dir/

#####Check if we have received all the files present in the master file list#####

while IFS= read -r f; do
	if test -f $src_dir/$f* ; then
		echo "$f file exists in $src_dir " 2>&1 | tee -a $log_dir/$log_file_name
	else
		echo "Expected file $f does NOT exist in Informatica source file location." 2>&1 | tee -a $log_dir/$log_file_name | tee -a $log_dir/$file_dtl
	fi
	done < "$master_file"
	
count_records()
{
#File we are working with
myfile=$f
myfile_without_path=$(basename $myfile)

recs=`wc -l $myfile | cut -f1 -d" "`
let recs=`expr $recs - 1`

echo "There are $recs detail records in the file $myfile." 2>&1 | tee -a $log_dir/$log_file_name

trcnt=`tail -1 $myfile | tr -d '[A-Za-z]'`

#count after removing leading 0s
trcnt_num=$(echo $trcnt | sed 's/^0*//')

echo "Trailer says there are $trcnt_num records in the file $myfile." 2>&1 | tee -a $log_dir/$log_file_name

##compare header and trailer counts
if [ $recs -ne $trcnt_num ]; then
	echo "Count does NOT match for file $myfile - expected record count: $trcnt_num | actual record count: $recs." 2>&1 | tee -a $log_dir/$log_file_name
	echo "Count does NOT match for file $myfile_without_path - expected record count: $trcnt_num | actual record count: $recs."  >&1 | tee -a $log_dir/$file_dtl
fi
}

for f in $src_dir/*.dat; do count_records $f; done


trailer_rec_name_chk()
{
#File we are working with
myfile=$f
myfile_without_path=$(basename $myfile)
myfile_without_pathandext=$(basename $myfile .txt.processed)
myfile_without_date=$(echo $myfile_without_pathandext | cut -d_ -f1)

trcnt=`tail -1 $myfile | cut -f1 -d"|"`

echo "Trailer record name is $trcnt in the file $myfile." 2>&1 | tee -a $log_dir/$log_file_name
echo "Trailer record name is $trcnt in the file $myfile_without_path."  2>&1 | tee -a $log_dir/$log_file_name
echo "$myfile_without_date" 2>&1 | tee -a $log_dir/$log_file_name

##compare header and trailer counts
if [ "$myfile_without_date" != "$trcnt" ]; then
	echo "Filename of file $myfile does NOT match with Trailer Record Name." 2>&1 | tee -a $log_dir/$log_file_name
	echo "Filename of file $myfile_without_path does NOT match with Trailer Record Name of $trcnt."  >&1 | tee -a $log_dir/$file_dtl
fi

}

##for f in $src_dir/*.dat; do trailer_rec_name_chk $f; done 

##mail -s "test" vijaya.kancherla@das.ohio.gov < /u01/mw/inf/informatica/pc105/log/$file_dtl 2>&1 | tee -a $log_dir/$log_file_name
