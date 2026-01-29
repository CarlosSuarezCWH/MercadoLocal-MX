output "load_balancer_dns" {
  value = module.alb.dns_name
}

output "database_endpoint" {
  value = module.rds.endpoint
}

output "redis_endpoint" {
  value = module.elasticache.primary_endpoint_address
}
