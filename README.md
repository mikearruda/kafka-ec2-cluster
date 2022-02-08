# Kafka/ZooKeeper Cluster on EC2
This project deploys a Kafka and ZooKeeper cluster on EC2.
## Usage
1. Install Terraform
2. Set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables
3. Run `terraform init`
4. Run `terraform plan`
5. Run `terraform apply`
6. To delete all resources, run `terraform destroy`
## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| broker_count | Number of Apache Kafka brokers to deploy | number | `3` | no |
| instance_type | EC2 instance type | string | `m5.2xlarge` | no |
| kafka_binary | Kafka binary URL | string | `https://archive.apache.org/dist/kafka/2.8.0/kafka_2.13-2.8.0.tgz` | no |
| number_of_zones | The number of isolated subnets/zones in which brokers are distributed | number | `3` | no |
| volume_size | EBS storage volume per broker (GiB) | number | `50` | no |

---

<i>The contents of this repository represent my viewpoints and not of my past or current employers, including Amazon Web
Services (AWS). All third-party libraries, modules, plugins, and SDKs are the property of their respective owners.</i>