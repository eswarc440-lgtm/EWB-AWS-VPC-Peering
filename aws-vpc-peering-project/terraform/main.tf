# Reconstructed example, not imported from the manually created AWS lab.
# This creates NEW resources if applied. Do not apply against the existing lab.

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_vpc" "a" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "Project-VPC-A" }
}

resource "aws_vpc" "b" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "Project-VPC-B" }
}

resource "aws_subnet" "a_public" {
  vpc_id                  = aws_vpc.a.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags                    = { Name = "Public-Subnet-A" }
}

resource "aws_subnet" "a_private" {
  vpc_id                  = aws_vpc.a.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags                    = { Name = "Private-Subnet-A" }
}

resource "aws_subnet" "b_private" {
  vpc_id                  = aws_vpc.b.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags                    = { Name = "Private-Subnet-B" }
}

resource "aws_internet_gateway" "a" {
  vpc_id = aws_vpc.a.id
  tags   = { Name = "Project-IGW" }
}

resource "aws_vpc_peering_connection" "a_to_b" {
  vpc_id      = aws_vpc.a.id
  peer_vpc_id = aws_vpc.b.id
  auto_accept = true # Same AWS account + same Region only
  tags        = { Name = "VPC-A-to-VPC-B" }
}

resource "aws_route_table" "a_public" {
  vpc_id = aws_vpc.a.id
  tags   = { Name = "ewb-rt-a-public" }
}

resource "aws_route_table" "a_private" {
  vpc_id = aws_vpc.a.id
  tags   = { Name = "ewb-rt-a-private" }
}

resource "aws_route_table" "b_private" {
  vpc_id = aws_vpc.b.id
  tags   = { Name = "ewb-rt-b-private" }
}

resource "aws_route" "a_public_internet" {
  route_table_id         = aws_route_table.a_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.a.id
}

resource "aws_route" "a_public_to_b" {
  route_table_id            = aws_route_table.a_public.id
  destination_cidr_block    = aws_vpc.b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.a_to_b.id
}

resource "aws_route" "a_private_to_b" {
  route_table_id            = aws_route_table.a_private.id
  destination_cidr_block    = aws_vpc.b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.a_to_b.id
}

resource "aws_route" "b_private_to_a" {
  route_table_id            = aws_route_table.b_private.id
  destination_cidr_block    = aws_vpc.a.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.a_to_b.id
}

resource "aws_route_table_association" "a_public" {
  subnet_id      = aws_subnet.a_public.id
  route_table_id = aws_route_table.a_public.id
}

resource "aws_route_table_association" "a_private" {
  subnet_id      = aws_subnet.a_private.id
  route_table_id = aws_route_table.a_private.id
}

resource "aws_route_table_association" "b_private" {
  subnet_id      = aws_subnet.b_private.id
  route_table_id = aws_route_table.b_private.id
}

resource "aws_security_group" "bastion" {
  name        = "ewb-sg-bastion"
  description = "Restrict bastion SSH to one admin public IP"
  vpc_id      = aws_vpc.a.id

  ingress {
    description = "SSH from operator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ssh_cidr]
  }

  egress {
    description = "Teaching lab: allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ewb-sg-bastion" }
}

resource "aws_security_group" "app_a" {
  name        = "ewb-sg-app-a"
  description = "SSH from bastion; ICMP echo from App B"
  vpc_id      = aws_vpc.a.id

  ingress {
    description = "SSH from bastion private IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.1.10/32"]
  }

  ingress {
    description = "ICMPv4 echo request from App B"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.20.1.10/32"]
  }

  egress {
    description = "Teaching lab: allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ewb-sg-app-a" }
}

resource "aws_security_group" "app_b" {
  name        = "ewb-sg-app-b"
  description = "SSH from bastion; ICMP echo from App A"
  vpc_id      = aws_vpc.b.id

  ingress {
    description = "SSH from bastion private IP across peering"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.1.10/32"]
  }

  ingress {
    description = "ICMPv4 echo request from App A"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.10.2.10/32"]
  }

  egress {
    description = "Teaching lab: allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ewb-sg-app-b" }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.a_public.id
  private_ip                  = "10.10.1.10"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = var.key_pair_name
  depends_on                  = [aws_route.a_public_internet]
  metadata_options { http_tokens = "required" }
  tags = { Name = "ewb-bastion" }
}

resource "aws_instance" "app_a" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.a_private.id
  private_ip                  = "10.10.2.10"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.app_a.id]
  key_name                    = var.key_pair_name
  metadata_options { http_tokens = "required" }
  tags = { Name = "ewb-app-a" }
}

resource "aws_instance" "app_b" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.b_private.id
  private_ip                  = "10.20.1.10"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.app_b.id]
  key_name                    = var.key_pair_name
  depends_on                  = [aws_route.b_private_to_a]
  metadata_options { http_tokens = "required" }
  tags = { Name = "ewb-app-b" }
}
