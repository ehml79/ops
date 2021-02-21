


mkdir -p /data/service/mongodb
mkdir -p /data/service/mongodb/conf
mkdir -p /data/service/mongodb/data/{rs1,rs2,rs3}

echo 'export MONGODB_HOME=/data/service/mongodb' > /etc/profile.d/mongodb.sh
echo 'export PATH=$MONGODB_HOME/bin:$PATH' >> /etc/profile.d/mongodb.sh
source /etc/profile.d/mongodb.sh





cat > /data/service/mongodb/conf/rs1.conf <<EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/service/mongodb/rs1.log

# Where and how to store data.
storage:
  dbPath: /data/service/mongodb/data/rs1
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/service/mongodb/rs1.pid

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0
  unixDomainSocket:
    enabled: false

#security:
#  authorization: enabled

#operationProfiling:
replication:
  oplogSizeMB: 20
  replSetName: rs0

#sharding:
EOF




cat > /data/service/mongodb/conf/rs2.conf <<EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/service/mongodb/rs1.log

# Where and how to store data.
storage:
  dbPath: /data/service/mongodb/data/rs2
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/service/mongodb/rs1.pid

# network interfaces
net:
  port: 27018
  bindIp: 0.0.0.0
  unixDomainSocket:
    enabled: false

#security:
#  authorization: enabled

#operationProfiling:
replication:
  oplogSizeMB: 20
  replSetName: rs0

#sharding:
EOF




cat > /data/service/mongodb/conf/rs3.conf <<EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/service/mongodb/rs3.log

# Where and how to store data.
storage:
  dbPath: /data/service/mongodb/data/rs3
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/service/mongodb/rs3.pid

# network interfaces
net:
  port: 27019
  bindIp: 0.0.0.0
  unixDomainSocket:
    enabled: false

#security:
#  authorization: enabled

#operationProfiling:
replication:
  oplogSizeMB: 20
  replSetName: rs0

#sharding:
EOF




mongod -f /data/service/mongodb/conf/rs1.conf
mongod -f /data/service/mongodb/conf/rs2.conf
mongod -f /data/service/mongodb/conf/rs3.conf

rs.status()

rs.initiate({"_id":"rs0","members":[ {"_id":1,"host":"localhost:27017"}, {"_id":2,"host":"localhost:27018"}, {"_id":3,"host":"localhost:27019"} ]})

rs.isMaster()


mongo --port 27017
mongo --port 27018
mongo --port 27019