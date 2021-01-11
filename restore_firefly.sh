#!/bin/bash

# Firefly III Docker restore script, by Taylor Smith

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
