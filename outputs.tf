output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_b.id
}

output "db_instance_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "ec2_instance_a_ip" {
  value = aws_instance.ec2_a.public_ip
}

output "ec2_instance_b_ip" {
  value = aws_instance.ec2_b.public_ip
}