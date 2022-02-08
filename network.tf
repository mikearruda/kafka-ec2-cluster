resource "aws_vpc" "kafka" {
  cidr_block = "10.0.0.0/20"
  tags = merge({
    Name = "Kafka"
  }, local.tags)
}

resource "aws_internet_gateway" "kafka" {
  vpc_id = aws_vpc.kafka.id
  tags = merge({
    Name = "Kafka-Internet-Gateway"
  }, local.tags)
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "kafka" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.kafka]
  tags = merge({
    Name = "Kafka-NAT-Gateway"
  }, local.tags)
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.kafka.id
  cidr_block = "10.0.10.0/28"
  tags = merge({
    Name = "Kafka-Public-Subnet"
  }, local.tags)
}

resource "aws_subnet" "private" {
  count             = var.number_of_zones
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/28"
  vpc_id            = aws_vpc.kafka.id
  tags = merge({
    Name = "Kafka-Private-Subnet-${count.index}"
  }, local.tags)
}

resource "aws_route_table" "igw" {
  vpc_id = aws_vpc.kafka.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kafka.id
  }
}

resource "aws_route_table" "ngw" {
  vpc_id = aws_vpc.kafka.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.kafka.id
  }
}

resource "aws_route_table_association" "igw" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.igw.id
}

resource "aws_route_table_association" "ngw" {
  count          = var.number_of_zones
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.ngw.id
}