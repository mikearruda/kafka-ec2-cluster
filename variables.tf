variable "broker_count" {
  type    = number
  default = 3
}

variable "instance_type" {
  type    = string
  default = "m5.2xlarge"
}

variable "kafka_binary" {
  type    = string
  default = "https://archive.apache.org/dist/kafka/2.8.0/kafka_2.13-2.8.0.tgz"
}

variable "number_of_zones" {
  type    = number
  default = 3
}

variable "volume_size" {
  type    = number
  default = 50
}