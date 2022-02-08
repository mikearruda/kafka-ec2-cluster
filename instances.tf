resource "tls_private_key" "kafka" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kafka" {
  key_name   = "Kafka EC2 Keypair"
  public_key = tls_private_key.kafka.public_key_openssh
}

resource "aws_kms_key" "kafka" {
  description = "Kafka KMS Key"
  tags        = local.tags
}

resource "aws_instance" "kafka" {
  ami                  = data.aws_ami.amzn2_linux.id
  count                = var.broker_count
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.kafka_profile.name
  key_name             = aws_key_pair.kafka.key_name
  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.kafka.arn
    volume_size = var.volume_size
    volume_type = "gp3"
  }
  subnet_id              = element(aws_subnet.private.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.kafka.id]
  user_data = templatefile("${path.module}/init.tpl", {
    broker_count = var.broker_count
    kafka_binary = var.kafka_binary
  })
  tags = {
    Name      = "Kafka-${count.index + 1}"
    createdBy = "terraform"
  }
}