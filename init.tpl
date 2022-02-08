#!/bin/bash

# Variable declaration
EC2_REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//'`
INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
INSTANCE_INDEX=`curl -s http://169.254.169.254/latest/meta-data/tags/instance/Name | awk -F- '{print $NF}'`
ZK_CONNECT_STRING=""

# Install patches and dependencies
yum update -y
yum install java-1.8.0-openjdk-headless -y

# Wait for all instances to start
until [[ $(aws ec2 describe-instances --region $EC2_REGION --filters 'Name=tag:Name,Values=Kafka-*' 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].InstanceId' --output text | wc -l) -eq ${broker_count} ]]
do
  sleep 15
done

INSTANCE_IDS=`aws ec2 describe-instances --region $EC2_REGION --filters 'Name=tag:Name,Values=Kafka-*' 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].InstanceId' --output text | xargs`

# Install
curl "${kafka_binary}" -o /tmp/kafka.tgz
mkdir /kafka && cd /kafka
tar -zxvf /tmp/kafka.tgz --strip 1

# Configure ZooKeeper
mkdir -p data/zookeeper
echo "$INSTANCE_INDEX" >> data/zookeeper/myid
sed -i "s/dataDir=.*/dataDir=\/kafka\/data\/zookeeper/g" config/zookeeper.properties
tee -a config/zookeeper.properties << END
initLimit=5
syncLimit=2
tickTime=2000
END

for INSTANCE in $INSTANCE_IDS; do
  IP=$(aws ec2 describe-instances --region $EC2_REGION --filters "Name=instance-id,Values=$INSTANCE" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
  HOSTNAME=$(aws ec2 describe-instances --region $EC2_REGION --filters "Name=instance-id,Values=$INSTANCE" --query 'Reservations[*].Instances[*].PrivateDnsName' --output text)
  INDEX=$(aws ec2 describe-instances --region $EC2_REGION --filters "Name=instance-id,Values=$INSTANCE" --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text | awk -F- '{print $NF}')
  if [[ $INDEX -eq $INSTANCE_INDEX ]]; then
    echo "server.$INDEX=0.0.0.0:2888:3888" >> config/zookeeper.properties
    ZK_CONNECT_STRING+="$IP:2181,"
  else
    echo "server.$INDEX=$IP:2888:3888" >> config/zookeeper.properties
    ZK_CONNECT_STRING+="$IP:2181,"
    echo "$IP $HOSTNAME" >> /etc/hosts
  fi
done

# Start ZooKeeper
nohup bin/zookeeper-server-start.sh -daemon config/zookeeper.properties > /dev/null 2>&1 &

# Configure Kafka
mkdir -p data/kafka
sed -i "s/broker.id=.*/broker.id=$INSTANCE_INDEX/g" config/server.properties
sed -i "s/log.dirs=.*/log.dirs=\/kafka\/data\/kafka/g" config/server.properties
sed -i "s/zookeeper.connect=.*/zookeeper.connect=$ZK_CONNECT_STRING/g" config/server.properties

# Start Kafka
sleep 5
nohup bin/kafka-server-start.sh -daemon config/server.properties > /dev/null 2>&1 &