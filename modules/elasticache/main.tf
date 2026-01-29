resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_data_subnets
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project_name}-${var.environment}-redis"
  description                = "Redis for WordPress Object Cache"
  node_type                  = "cache.t3.micro" # Free Tier usage
  port                       = 6379
  parameter_group_name       = "default.redis7"
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = var.security_group_ids
  automatic_failover_enabled = false # Not available for t3.micro usually, keeps it simple/cheap
  num_cache_clusters         = 1     # Free tier, one node
  multi_az_enabled           = false # Free tier
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true 
}
