<div align="center">
  <h1>
    MongoDB replica
  </h1>
  <p>
    Simple tool for create hardened(+Full TLS communication) MongoDB replication with extra tools
  </p>
  <p>
    <a href="https://github.com/aasaam/mongodb-replica/blob/master/LICENSE">
      <img alt="License" src="https://img.shields.io/github/license/aasaam/mongodb-replica">
    </a>
  </p>
</div>

## Usage

```bash
sudo ./prepare.sh (name space) (domain) [number of nodes] [initialize port]
```

- option `(name space)` required, consider variable as subdomain, like `app0`
- option `(domain)` required, it's actually your domain name, `cluster-domain.tld` or `mongo.cluster-domain.tld`
- option `[number of nodes]` is optional and supported following props: `3`, `5` and `7`
- option `[initialize port]` is optional and default is `27000` and must be `>= 1300` and `<= 48000`

```bash
sudo ./prepare.sh app0 cluster-domain.tld
# sudo ./prepare.sh [name space] [domain] [number of nodes] [initialize port]
# other examples
# sudo ./prepare.sh app0 cluster-domain.tld 3 28000
# sudo ./prepare.sh app0 cluster-domain.tld 5 12000
# sudo ./prepare.sh app0 cluster-domain.tld 7

# then your files are in deploy/app0
# scp to your servers deploy/app0/node0 -> node0
# scp to your servers deploy/app0/node0 -> node1
# scp to your servers deploy/app0/node0 -> node2
```

### DNS

Set your dns for following servers, for example:

```
app0-mongo-0.cluster-domain.tld A record 192.168.0.100
app0-mongo-1.cluster-domain.tld A record 192.168.0.101
app0-mongo-2.cluster-domain.tld A record 192.168.0.102
```

### Initialize

For first initialize you must follow these steps:

#### For all nodes

1. Allow list of ips or subnet want to access cluster via nginx acl, server ips and application ips
    ```
    nano nginx/acl.conf
    ```

1. Set data path variables
    ```
    mv .env.sample .env
    nano .env
    ```

1. Then up the container

    ```bash
    docker-compose up -d
    ```

1. Then go to first node for first initialize

    ```bash
    # create replica wait about 30 seconds to replica start
    ./init-replica.sh
    # you have to see: { ok: 1 }

    # then enable auth
    ./init-auth.sh
    # you have to see: { ok: 1 }
    ```

### Create db and user

On any node

```bash
# create app0 with random user and db suffix with generated password
# also guide for set replica connection string
./create-db-user.sh app0
```

### Backup

For create backup on any node:

```bash
# daily backup if exist will be skipped
./backup.create.sh db-app0-abcf0123

# now backup
./backup.create.sh db-app0-abcf0123 now
```

For restore backup on any node

```bash
# will be drop old database and restore from file
./backup.restore.sh db-app0-abcf0123 mongo-aps0-db-aps0-abcf0123-full-2022-01-21.1677300000.123456789.tgz
```

<div>
  <p align="center">
    <img alt="aasaam software development group" width="64" src="https://raw.githubusercontent.com/aasaam/information/master/logo/aasaam.svg">
    <br />
    aasaam software development group
  </p>
</div>
