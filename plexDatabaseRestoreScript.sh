#!/bin/bash

# Restore a Plex database.
# Author Scott Smereka
# Version 1.0

# Script Tested on:
# Ubuntu 12.04 on 2/2/2014	[ OK ]

# Plex Database Location.  The trailing slash is
# needed and important for rsync.
plexDatabase="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/"

# Location to backup the directory to.
backupDirectory="/mnt/nfs/temp/backups/plexmediaserver/"

# Log file for script's output named with
# the script's name, date, and time of execution.
scriptName=$(basename ${0})
log="/mnt/nfs/temp/backups/logs/${scriptName}_`date +%m%d%y%H%M%S`.log"

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
  echo -e "${scriptName} requires root privledges.\n"
  echo -e "sudo $0 $*\n"
  exit 1
fi

# Create Log
echo -e "Starting Restore of Plex Database." > $log 2>&1
echo -e "------------------------------------------------------------\n" >> $log 2>&1

# Stop Plex
echo -e "\n\nStopping Plex Media Server." >> $log 2>&1
echo -e "------------------------------------------------------------\n" >> $log 2>&1
sudo /usr/bin/systemctl stop plexmediaserver.service  >> $log 2>&1

# Restore database
echo -e "\n\nStarting Database Restore." >> $log 2>&1
echo -e "------------------------------------------------------------\n" >> $log 2>&1
sudo /usr/bin/rsync -av --delete --exclude="Logs/" --exclude="Crash Reports/" "$backupDirectory" "$plexDatabase" >> $LOG 2>&1

# Update database permissions
echo -e "\n\nUpdating Database Permissions." >> $log 2>&1
echo -e "------------------------------------------------------------\n" >> $log 2>&1
sudo /usr/bin/chown -R plex:plex "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/" >> $log 2>&1

# Restart Plex
echo -e "\n\nStarting Plex Media Server." >> $log 2>&1
echo -e "------------------------------------------------------------\n" >> $log 2>&1
sudo /usr/bin/systemctl start plexmediaserver.service  >> $log 2>&1

# Done
echo -e "\n\nRestore Complete." >> $log 2>&1
