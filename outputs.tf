output "ssh_private_key_pem" {
  value = tls_private_key.kafka.private_key_pem
}

output "ssh_public_key_pem" {
  value = tls_private_key.kafka.public_key_pem
}

output "kafka_instances" {
  value = aws_instance.kafka.*.private_ip
}