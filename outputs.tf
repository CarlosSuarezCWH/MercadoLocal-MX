output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.compute.alb_dns_name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.database.db_endpoint
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.storage.bucket_id
}

output "cloudfront_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = module.storage.cloudfront_domain
}
