# mongodb-backup-s3

This image runs mongodump to backup data using cronjob to an s3 bucket

## Vendigo Fork

This fork is based on [halvves/mongodb-backup-s3](http://github.com/halvves/mongodb-backup-s3)

It has the following changes:

  * Runs on alpine linux so that the image is TINY
  * Removes port directives, as we can use replicaSets or host:port.
  * Specify region for buckets with '.' in the name, as is required by AWS
  * Upgrades aws-cli from an ancient version in 'apt' to the latest python pip one.
  * Removes restore on restart, because that is a crazy idea.

Also removes the ability to initiate a restore on startup, as this won't work well with replicasets.

## Usage:

```
docker run -d \
  --env AWS_ACCESS_KEY_ID=awsaccesskeyid \
  --env AWS_SECRET_ACCESS_KEY=awssecretaccesskey \
  --env BUCKET=s3bucket
  --env BUCKET_REGION=eu-west-1
  --env MONGODB_HOST=mongodb.host \
  --env MONGODB_USER=admin \
  --env MONGODB_PASS=password \
  vendigo/mongo-backup:latest
```

If you link `vendigo/mongo-backup:latest` to a mongodb container with an alias named mongodb, this image will try to auto load the `host`, `port`, `user`, `pass` if possible. Like this:

```
docker run -d \
  --env AWS_ACCESS_KEY_ID=myaccesskeyid \
  --env AWS_SECRET_ACCESS_KEY=mysecretaccesskey \
  --env BUCKET=mybucketname \
  --env BUCKET_REGION=eu-west-1
  --env BACKUP_FOLDER=a/sub/folder/path/ \
  --env INIT_BACKUP=true \
  --link my_mongo_db:mongodb \
  vendigo/mongo-backup:latest
```

Add to a docker-compose.yml to enhance your robotic army:

For automated backups
```
mongodbbackup:
  image: 'vendigo/mongo-backup:latest'
  links:
    - mongodb
  environment:
    - AWS_ACCESS_KEY_ID=myaccesskeyid
    - AWS_SECRET_ACCESS_KEY=mysecretaccesskey
    - BUCKET=my-s3-bucket
    - BUCKET_REGION=eu-west-1
    - BACKUP_FOLDER=prod/db/
  restart: always
```

Or use `INIT_RESTORE` with `DISABLE_CRON` for seeding/restoring/starting a db (great for a fresh instance or a dev machine)
```
mongodbbackup:
  image: 'vendigo/mongo-backup:latest'
  links:
    - mongodb
  environment:
    - AWS_ACCESS_KEY_ID=myaccesskeyid
    - AWS_SECRET_ACCESS_KEY=mysecretaccesskey
    - BUCKET=my-s3-bucket
    - BUCKET_REGION=eu-west-1
    - BACKUP_FOLDER=prod/db/
    - INIT_RESTORE=true
    - DISABLE_CRON=true
```

## Parameters

`AWS_ACCESS_KEY_ID` - your aws access key id (for your s3 bucket)

`AWS_SECRET_ACCESS_KEY`: - your aws secret access key (for your s3 bucket)

`BUCKET`: - your s3 bucket

`BUCKET_REGION`: - region of your s3 bucket

`BACKUP_FOLDER`: - name of folder or path to put backups (eg `myapp/db_backups/`). defaults to root of bucket.

`MONGODB_HOST` - the host/ip/replicaSet+hosts of your mongodb database

`MONGODB_USER` - the username of your mongodb database. If MONGODB_USER is empty while MONGODB_PASS is not, the image will use admin as the default username

`MONGODB_PASS` - the password of your mongodb database

`MONGODB_DB` - the database name to dump. If not specified, it will dump all the databases

`EXTRA_OPTS` - any extra options to pass to mongodump command

`CRON_TIME` - the interval of cron job to run mongodump. `0 3 * * *` by default, which is every day at 03:00hrs.

`TZ` - timezone. default: `US/Eastern`

`CRON_TZ` - cron timezone. default: `US/Eastern`

`INIT_BACKUP` - if set, create a backup when the container launched

`DISABLE_CRON` - if set, it will skip setting up automated backups. good for when you want to use this container to seed a dev environment.

## Restore from a backup

To see the list of backups, you can run:
```
docker exec mongodb-backup-s3 /listbackups.sh
```

To restore database from a certain backup, simply run (pass in just the timestamp part of the filename):

```
docker exec mongodb-backup-s3 /restore.sh 20170406T155812
```

To restore latest just:
```
docker exec mongodb-backup-s3 /restore.sh
```

## Acknowledgements

  * forked from [futurist](https://github.com/futurist)'s fork of [tutumcloud/mongodb-backup](https://github.com/tutumcloud/mongodb-backup)
