#!/bin/bash
# Firefly III Docker restore script, by Taylor Smith

# get & sanitize location of backups
BACKUP_DIR="$(realpath $1)"

# generate volume names - if there is a prefix, it is the 2nd arg
VOL_ROOT="firefly_iii"
if [ "$#" -eq 2 ]; then
    VOL_ROOT="${2}_${VOL_ROOT}"
fi
VOLUMES="${VOL_ROOT}_upload ${VOL_ROOT}_db"

# --------------------

VOL_ROOT="${VOL_PREFIX}_firefly_iii"
VOLUMES="${VOL_ROOT}_upload ${VOL_ROOT}_db"

echo "restoring from archives in $BACKUP_DIR"

# check that all volumes do not exists
for VOL in $VOLUMES
do
    echo "-- checking that volume $VOL doesn't exist"
    if docker volume ls -q | grep -q "^$VOL$"
    then
        errornotification "Cannot restore - volume exists" \
            "Volume $VOL already exists! Please rename or delete it."
        exit 1
    fi
done

for VOL in $VOLUMES
do
    echo "-- restoring volume $VOL"
    docker run --rm \
        --mount type=volume,source=$VOL,dst=/recover \
        --mount type=bind,src=$BACKUP_DIR,dst=/backup,ro \
        alpine tar -xvf /backup/$VOL.tar -C /recover --strip 1
done

echo "done!"
