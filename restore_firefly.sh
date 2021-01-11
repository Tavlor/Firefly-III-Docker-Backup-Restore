#!/bin/bash

# Firefly III Docker restore script, by Taylor Smith
# restores Firefly volumes from the tar archives produced by the backup script
# To use:
# - Set "BACKUP_DIR" and "VOL_PREFIX" according to your setup
# - Stop your Firefly containers
# - Remove any existing (corrupt/empty) Firefly volumes before running (be
#   careful if testing! You CANNOT get them back!)
# - Test restoration manually before relying on this

# a note for docker-compose users:
# docker-compose usually adds the folder name containing your yaml file at the
# beginning of named volumes it creates (i.e. if you launch firefly using
# ~/finance/docker-compose.yml, then your volumes will start with "finance_")
# The VOL_PREFIX variable should be this folder's name, follwed by an
# underscore. If you plan on storing the docker-compose file in a different
# folder after restoring, change the prefix now.

# directory where your backups will be found
BACKUP_DIR="$(realpath $1)"
# if you don't use docker-compose, set this to an empty string.
VOL_PREFIX="tws_"

# --------------------

VOL_ROOT="${VOL_PREFIX}firefly_iii"
VOLUMES="${VOL_ROOT}_upload ${VOL_ROOT}_db"

echo $BACKUP_DIR

for VOL in $VOLUMES
do
    echo "-- restoring volume $VOL"
    docker run --rm \
        --mount type=volume,source=$VOL,dst=/recover \
        --mount type=bind,src=$BACKUP_DIR,dst=/backup,ro \
        alpine tar -xvf /backup/$VOL.tar -C /recover --strip 1
done

echo "done!"
