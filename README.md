# Firefly III Docker - backup and restore scripts
Scripts I've developed to make my life easier. Mounts the volumes used by Firefly and produces tar archives (or unpacks archives, when restoring).

# Features
- Checks that docker is running and the volumes exist before making backups (if a volume doesn't exist, an empty volume is created, which will wipe out an existing backup)
- Can send push notifications - examples for a few OS's are included

# Usage
## Before Running
- prepare your docker environment
	- make sure docker is running
- Edit the `VOL_PREFIX` variable:
	- If you don't use docker-compose, it should be empty
	```sh
	VOL_PREFIX=""
	```
	- If you use docker-compose, it is the name of the folder that holds your `docker-compose.yml`, with an underscore (i.e. if you launch firefly using ~/finance/docker-compose.yml, then your volumes will start with "finance_"). 
	```sh
	VOL_PREFIX="finance_"
	```
### When Backing Up
- Close out of firefly III, but don't worry about stoping its containers.
- Configure notifications: Edit `notification ()` and `errornotification ()` for your system. Make sure that lines for other OS's are commented out.
### When Restoring
- stop your Firefly containers
- Remove any existing (corrupt/empty) Firefly volumes before running (**be careful if testing!** You **CANNOT** get volumes back! Consider copying your `docker-compose.yml` to a temporary folder, and using that prefix.)
## Running
The only argument is the backup directory:
```sh
./backup_firefly.sh ~/backups/firefly/
```
