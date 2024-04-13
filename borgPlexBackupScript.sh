#!/bin/sh

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO='/mnt/nfs/temp/backups/plex'

# See the section "Passphrase notes" for more infos.
export BORG_PASSPHRASE='plex'

# Log file for script's output named with 
# the script's name, date, and time of execution.
scriptName=$(basename ${0})
log="/mnt/nfs/temp/backups/logs/${scriptName}_`date +%m%d%y%H%M%S`.log"

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >> $log 2>&1; }

info "Starting backup"

# Create Log
info "Staring Backup of Plex Database."
info "------------------------------------------------------------"

# Stop Plex
info "Stopping Plex Media Server."
info "------------------------------------------------------------"
sudo /usr/bin/systemctl stop plexmediaserver.service  >> $log 2>&1

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

/usr/local/bin/borg create             \
    --verbose                          \
    --filter AME                       \
    --list                             \
    --stats                            \
    --show-rc                          \
    --compression lz4                  \
    --exclude-caches                   \
    --exclude '**/Preferences.bak'     \
    --exclude '**/.LocalAdminToken'    \
    --exclude '**/plexmediaserver.pid' \
    --exclude '**/Cache/*'             \
    --exclude '**/Codecs/*'            \
    --exclude '**/Crash Reports/*'     \
    --exclude '**/Diagnostics/*'       \
    --exclude '**/Drivers/*'           \
    --exclude '**/Logs/*'              \
    --exclude '**/Updates/*'           \
                                       \
    ::'{hostname}-{now}'               \
    /var/lib/plexmediaserver  >> $log 2>&1                            

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-*' matching is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

/usr/local/bin/borg prune           \
    --list                          \
    --glob-archives '{hostname}-*'  \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6

prune_exit=$?

# actually free repo disk space by compacting segments

info "Compacting repository"

/usr/local/bin/borg compact

compact_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune, and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune, and/or Compact finished with warnings"
else
    info "Backup, Prune, and/or Compact finished with errors"
fi

# Restart Plex
info "Starting Plex Media Server."
info "------------------------------------------------------------"
sudo /usr/bin/systemctl start plexmediaserver.service  >> $log 2>&1

# Done
info "Backup Complete."


exit ${global_exit}
