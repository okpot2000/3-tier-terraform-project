output "vpc_id" {
value = aws_vpc.main_vpc.id 
}

output "apci_jupiter_public_subnet_az_1a" {
  value = aws_subnet.apci_jupiter_public_subnet_az_1a.id
}

output "apci_jupiter_public_subnet_az_1c" {
  value = aws_subnet.apci_jupiter_public_subnet_az_1c.id
}