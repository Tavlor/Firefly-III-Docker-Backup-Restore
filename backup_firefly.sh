#!/bin/bash

# Firefly III Docker backup script, by Taylor Smith
# creates 2 tar archives from the Firefly volumes; checks that docker is
# running and the volumes exist before making backups (if a volume doesn't
# exist, an empty volume is created, which will wipe out an existing backup)
# To use:
# - Set "BACKUP_DIR" and "VOL_PREFIX" according to your setup
# - Adjust notification() to match your system - comment out the parts that
#   are for other operating systems
# - Test backup and restoration manually before setting up automation

# a note for docker-compose users:
# docker-compose usually adds the folder containing your yaml file at the
# beginning of named volumes it creates (i.e. if you launch firefly using
# ~/finance/docker-compose.yml, then your volumes will start with "finance_").
# The VOL_PREFIX variable should be this folder's name, follwed by an
# underscore.

# directory where your backups will go
BACKUP_DIR="$(realpath $1)"
# if you don't use docker-compose, set this to an empty string
VOL_PREFIX="tws_"

# helper functions to notify you
notification () {
    # arguments: 1 title, 2 message
    # add whatever you want - email, push notification, carrier pigeon dispatch
    
    # macOS - popup notification
    # osascript -e 'on run argv
    # display notification item 2 of argv with title item 1 of argv subtitle "Firefly III Backup"
    # end run' "$1" "$2"
    
    # GNOME - popup notification
    notify-send "Firefly III Backup: $1" "$2"

    # stdout - goes into logs
    printf "$(date) $1\n\t$2\n"
}

errornotification () {
    # arguments: 1 title, 2 message
    # add whatever you want - email, push notification, carrier pigeon dispatch
    
    # macOS - popup notification
    # osascript -e 'on run argv
    # display notification item 2 of argv with title item 1 of argv subtitle "Firefly III Backup"
    # end run' "❗️ $1" "$2"
    
    # GNOME - popup notification
    notify-send "Firefly III Backup: ❗️ $1" "$2" -u critical

    # stdout - goes into logs
    printf "$(date) ❗️ $1\n\t$2\n"
}

# --------------------

VOL_ROOT="${VOL_PREFIX}firefly_iii"
VOLUMES="${VOL_ROOT}_upload ${VOL_ROOT}_db"

echo "+++++ starting at $(date) +++++"
echo "Backing up to $BACKUP_DIR"
echo "Using prefix: $VOL_PREFIX"
echo ${VOLUMES}

# --- error checking
# check that docker is running
if ! docker version; then
    errornotification "Backup failed" "Docker is not running!"
    exit 1
# check that backup folder exists
elif ! test -d "$BACKUP_DIR"; then
    errornotification "Backup folder doesn't exist" "$BACKUP_DIR is not a directory!"
    exit 1
fi
# check that all volumes exist
for VOL in $VOLUMES
do
    echo "-- checking the existence of volume $VOL"
    # if you're missing a volume, you probably need to restore!
    if ! docker volume ls -q | grep -q "^$VOL$"
    then
        errornotification "You're missing a volume" \
            "Volume $VOL is is missing! You should investigate NOW"
        exit 1
    fi
done
# TODO: optionally move existing backups to another place

# --- backup
for VOL in $VOLUMES
do
    echo "-- backing up volume $VOL"
    docker run --rm \
        --mount type=volume,source=$VOL,dst=/tmp,ro \
        --mount type=bind,src=$BACKUP_DIR,dst=/backup \
        alpine tar -czf "/backup/${VOL}.tar" /tmp
    if [ ! $? ]
    then
        # TODO: tee the error message into the notification
        errornotification "Backup failed" "Something happened while backing up Volume $VOL!"
        exit 1
    fi
done

# if you don't want a notification every time the script runs, comment this line out.
notification "✅ Backup passed" "your data is backed up!"
echo "----- done at $(date) -----"
