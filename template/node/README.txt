MongoDB replication __NAMESPACE__

- Management access data:

  * Administrator:
      username:   root
      password:   __ROOT_PASSWORD__

  * Administrator(read only):
      username:   root_readonly
      password:   __ROOT_READONLY_PASSWORD__

- Your application connection strings:

    * You will need files for tls communication (KEEP THEN ON SECURE PLACE):
      - cert/ca.pem
      - cert/client-combined.pem
      - cert/client-fullchain.pem
      - cert/client-key.pem
      - cert/client.pem

    * And your connection string will be:

      Replace `username`, `password` and `database` with your specified values on `./create-db-user.sh` command

      mongodb://username:password@__HOSTS_PORTS__/(database)?replicaSet=__NAMESPACE__

    * Do not forget modify nginx stream acl rules then restart containers(ALL NODES):

      nano nginx/acl.conf

- DNS records setup:

  Add following DNS records

    __NAMESPACE__-mongo-0.__DOMAIN__ # 3NODEREPLICA:N0
    __NAMESPACE__-mongo-1.__DOMAIN__ # 3NODEREPLICA:N1
    __NAMESPACE__-mongo-2.__DOMAIN__ # 3NODEREPLICA:N2
    __NAMESPACE__-mongo-0.__DOMAIN__ # 5NODEREPLICA:N0
    __NAMESPACE__-mongo-1.__DOMAIN__ # 5NODEREPLICA:N1
    __NAMESPACE__-mongo-2.__DOMAIN__ # 5NODEREPLICA:N2
    __NAMESPACE__-mongo-3.__DOMAIN__ # 5NODEREPLICA:N3
    __NAMESPACE__-mongo-4.__DOMAIN__ # 5NODEREPLICA:N4
    __NAMESPACE__-mongo-0.__DOMAIN__ # 7NODEREPLICA:N0
    __NAMESPACE__-mongo-1.__DOMAIN__ # 7NODEREPLICA:N1
    __NAMESPACE__-mongo-2.__DOMAIN__ # 7NODEREPLICA:N2
    __NAMESPACE__-mongo-3.__DOMAIN__ # 7NODEREPLICA:N3
    __NAMESPACE__-mongo-4.__DOMAIN__ # 7NODEREPLICA:N4
    __NAMESPACE__-mongo-5.__DOMAIN__ # 7NODEREPLICA:N5
    __NAMESPACE__-mongo-6.__DOMAIN__ # 7NODEREPLICA:N6

- Prometheus exporter:

  You can use 'telegraf-mongo-replica-exporter.conf' into your telegraf config directory, usually is '/etc/telegraf.d/'
  exporter listen only '127.0.0.1' you don't need to add firewall rules for it:

  http://127.0.0.1:__NODE_X_EXPORTER_PORT__/metrics

- Addition tools:

  * Create database with user and connection string:

    ./create-db-user.sh app1

  * Access shell

    for read only:
    ./mongosh.sh

    for full access:
    ./mongosh.sh root


- Useful commands

  * List of databases

    db.adminCommand({ listDatabases:1 })

  * List of users

    use admin;
    db.system.users.find();

  * Change password for user

    First better to generate random password on your bash

      openssl rand -base64 128 | tr -dc A-Za-z0-9 | head -c 48 ; echo ''

    Then open full access mongosh shell:

      use yourDbName
      db.changeUserPassword("username", "newPassword")
      // or via prompt [ not recommended ]
      db.changeUserPassword("username", passwordPrompt())

- Cron

  * Create cron entry for backup and garbage collection:

    cron.sh [db-full-backup-list] [db-collection-list-backup-daily] [max-load-average-for-start-backup]

      db-full-backup-list:
        List of `database` name separated by commas.

      db-collection-list-backup-daily:
        List of `database.collection` name separated by commas.

      max-load-average-for-start-backup:
        max-load-average-for-start-backup for cron.sh execution.
        Default is `2,4,6`, load 1, 5 and 15 minutes.

    Sample:

      0 * * * * /path/to/node/cron.sh 'db-sample-abcdef01,db-sample-abcdef02' 'db-sample-abcdef01.myCollection' '10,20,25'

      Run every-1-hour
        If load average is under `10,20,25`
        backup for check full daily backup on databases:
          - db-sample-abcdef01
          - db-sample-abcdef02
        also backup collection daily
          - db-sample-abcdef01.myCollection
