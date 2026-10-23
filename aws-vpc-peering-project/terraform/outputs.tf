output "vpc_a_id" {
  value       = aws_vpc.a.id
  description = "ID of newly created VPC A"
}

output "vpc_b_id" {
  value       = aws_vpc.b.id
  description = "ID of newly created VPC B"
}

output "peering_connection_id" {
  value       = aws_vpc_peering_connection.a_to_b.id
  description = "ID of newly created VPC peering connection"
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IPv4; only present if newly deployed"
}

output "app_a_private_ip" {
  value = aws_instance.app_a.private_ip
}

output "app_b_private_ip" {
  value = aws_instance.app_b.private_ip
}
