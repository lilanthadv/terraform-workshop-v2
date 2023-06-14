# Output vpc id
output "vpc" {
  value = aws_vpc.main.id
}

# Output public subnets ids
output "public_subnets" {
  value = aws_subnet.public_subnet[*].id
}

# Output private subnets ids
output "private_subnets" {
  value = aws_subnet.private_subnet[*].id
}
