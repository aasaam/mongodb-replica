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
sudo ./prepare.sh app0 cluster-domain.tld

# then your files are in deploy/app0
# scp to your servers deploy/app0/node0 -> node0
# scp to your servers deploy/app0/node0 -> node1
# scp to your servers deploy/app0/node0 -> node2
```

### DNS

Set your dns for following servers, for example:

```
app0-mongo-0.cluster-domain.tld A record 192.168.0.1
app0-mongo-1.cluster-domain.tld A record 192.168.0.2
app0-mongo-2.cluster-domain.tld A record 192.168.0.3
```

### Initialize

Go to each server and up the mongo instances:

```bash
docker-compose up -d
```

Then go to first node for first initialize

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

<div>
  <p align="center">
    <img alt="aasaam software development group" width="64" src="https://raw.githubusercontent.com/aasaam/information/master/logo/aasaam.svg">
    <br />
    aasaam software development group
  </p>
</div>
