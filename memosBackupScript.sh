#!/bin/bash

# Plex Database Location.  The trailing slash is 
# needed and important for rsync.
database="/home/qa/.memos/"

# Location to backup the directory to.
backupDirectory="/mnt/nfs/temp/backups/memos/"

# Log file for script's output named with 
# the script's name, date, and time of execution.
scriptName=$(basename ${0})
log="/mnt/nfs/temp/backups/logs/${scriptName}_`date +%m%d%y%H%M%S`.log"

# Create Log
echo -e "Staring Backup." > $log 2>&1
echo -e "------------------------------------------------------------\n" >> $log 2>&1

# Backup database
echo -e "\n\nStarting Backup." >> $log 2>&1
echo -e "------------------------------------------------------------\n" >> $log 2>&1
/usr/bin/rsync -av --delete "$database" "$backupDirectory" >> $log 2>&1

# Done
echo -e "\n\nBackup Complete." >> $log 2>&1
