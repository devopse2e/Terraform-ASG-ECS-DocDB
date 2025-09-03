output "vpc_id" {
    description = "vpc id "
    value = aws_vpc.main.id
  
}

output "public_subnet_ids" {
    description = "public subnet id's"
    value = aws_subnet.public[*].id
  
}

output "private_subnet_ids" {
    description = "private subnet id's"
    value = aws_subnet.private[*].id
  
}