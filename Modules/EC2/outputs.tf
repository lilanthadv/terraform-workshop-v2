output "id" {
  value = aws_instance.instance.id
}

output "arn" {
  value = aws_instance.instance.arn
}

output "public_ip" {
  value = var.associate_public_ip_address ? aws_instance.instance.public_ip : ""
}
