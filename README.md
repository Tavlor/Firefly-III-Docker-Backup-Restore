# Firefly III Docker - backup and restore scripts
Scripts I've developed to make my life easier. Mounts the volumes used by Firefly and produces tar archives (or unpacks archives, when restoring).

Learn more about Firefly III at https://www.firefly-iii.org/

# Features
- Checks that docker is running and the volumes exist before making backups (if a volume doesn't exist, an empty volume is created, which will wipe out an existing backup)
- Can send push notifications for backup status - examples for a few OS's are included

# Usage
## Setup Steps
### Backing Up
- Close out of firefly III in your browser, but don't worry about stoping its containers.
- Configure notifications: Edit `notification ()` and `errornotification ()` for your system. Make sure that lines for other OS's are commented out.

### Restoring
- stop your Firefly containers
- Rename or remove any existing (corrupt/empty) Firefly volumes before running (**be careful if testing!** You **CANNOT** get volumes back! Consider copying your `docker-compose.yml` to a temporary folder, and using that prefix.)
	- to rename a volume (from [this](https://github.com/moby/moby/issues/31154#issuecomment-360531460) github comment):
		```sh
		docker volume create --name <new_volume>
		docker run --rm -it -v <old_volume>:/from -v <new_volume>:/to alpine ash -c "cd /from ; cp -av . /to"
		docker volume rm <old_volume>
		```
	- the script will not allow overwriting existing volumes, as a safety measure.

## Running
Both commands have the same arguments:
```sh
./backup_firefly.sh <BACKUP DIRECTORY> <VOLUME PREFIX>
```
`<VOLUME PREFIX>` is optional
Examples:
```sh
# not using a volume prefix
./restore_firefly.sh ~/backup/firefly
# docker-compose from a folder named `ffiii`
./restore_firefly.sh ~/backups/firefly/ ffiii
```
- If you use docker-compose, the volume prefix is the name of the folder that holds your `docker-compose.yml` (i.e. if you launch firefly using ~/finance/docker-compose.yml, then your volumes will start with "finance").
