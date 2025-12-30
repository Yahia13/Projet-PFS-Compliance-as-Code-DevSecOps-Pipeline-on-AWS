output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

# Public Subnets (for ALB, NAT, public EC2)
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [
    aws_subnet.Public_subnet_1a.id,
    aws_subnet.Public_subnet_1b.id
  ]
}

# Private Subnets (for EKS nodes, private EC2)
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [
    aws_subnet.Private_subnet_1a.id,
    aws_subnet.Private_subnet_1b.id
  ]
}

# NAT Gateways (optional but useful for debug / defense)
output "nat_gateway_ids" {
  description = "NAT Gateway IDs (one per AZ)"
  value       = [
    aws_nat_gateway.eip_for_nat_1a.id,
    aws_nat_gateway.eip_for_nat_1b.id
  ]
}