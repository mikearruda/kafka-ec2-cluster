# Kafka/ZooKeeper Cluster on EC2

This project deploys a Kafka and ZooKeeper cluster on EC2.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| broker_count | Number of Apache Kafka brokers to deploy | number | `3` | no |
| instance_type | EC2 instance type | string | `m5.2xlarge` | no |
| kafka_binary | Kafka binary URL | string | `https://archive.apache.org/dist/kafka/2.8.0/kafka_2.13-2.8.0.tgz` | no |
| number_of_zones | The number of isolated subnets/zones in which brokers are distributed | number | `3` | no |
| volume_size | EBS storage volume per broker (GiB) | number | `50` | no |