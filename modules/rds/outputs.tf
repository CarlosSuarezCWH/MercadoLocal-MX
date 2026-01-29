output "endpoint" {
  value = aws_db_instance.main.address # Note: 'address' gives host, 'endpoint' gives host:port
}

output "port" {
  value = aws_db_instance.main.port
}

# Compatibility output if needed, but 'endpoint' is commonly host:port in Terraform RDS vs Cluster
# Let's double check. aws_db_instance.endpoint is host:port. aws_db_instance.address is host.
# Our user_data expects 'db_host'.
