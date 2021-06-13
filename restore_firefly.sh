#!/bin/bash
# Firefly III Docker restore script, by Taylor Smith

# get & sanitize location of backups
BACKUP_DIR="$(realpath $1)"

# generate volume names - if there is a prefix, it is the 2nd arg
VOL_ROOT="firefly_iii"
if [ "$#" -eq 2 ]; then
    VOL_ROOT="$2_${VOL_ROOT}"
fi
VOLUMES="${VOL_ROOT}_upload ${VOL_ROOT}_db"

# --------------------

echo "restoring from archives in $BACKUP_DIR"

# check that all recovery files exist
for VOL in $VOLUMES
do
    echo "-- checking for backup file $VOL.tar"
    if ! test -f "$BACKUP_DIR/$VOL.tar"; then
	echo " couldn't find backup file $VOL.tar! Does it have the wrong name?"
        exit 1	
    fi
done

# check that all volumes do not exist
for VOL in $VOLUMES
do
    echo "-- checking that volume $VOL doesn't exist"
    if docker volume ls -q | grep -q "^$VOL$"
    then
	echo "Volume $VOL already exists! Please rename or delete it."
        exit 1
    fi
done

# perform recovery
for VOL in $VOLUMES
do
    echo "-- restoring volume $VOL"
    docker run --rm \
        --mount type=volume,source=$VOL,dst=/recover \
        --mount type=bind,src=$BACKUP_DIR,dst=/backup,ro \
        alpine tar -xvf /backup/$VOL.tar -C /recover --strip 1
done

echo "done!"
