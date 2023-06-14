# Output vpc id
output "vpc_id" {
  value = aws_vpc.main.id
}

# Output public subnets ids
output "public_subnets_ids" {
  value = aws_subnet.public_subnet[*].id
}

# Output private subnets ids
output "private_subnets_ids" {
  value = aws_subnet.private_subnet[*].id
}
