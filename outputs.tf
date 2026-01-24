output "alb_dns_name" {
  description = "DNS name of the Load Balancer"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.default.endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 media bucket"
  value       = aws_s3_bucket.media.id
}
