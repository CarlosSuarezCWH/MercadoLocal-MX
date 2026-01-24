

module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  environment  = var.environment
}

module "database" {
  source                = "./modules/database"
  project_name          = var.project_name
  private_db_subnet_ids = module.networking.private_db_subnet_ids
  db_sg_id              = module.networking.db_sg_id
  db_password           = var.db_password
}

module "compute" {
  source                 = "./modules/compute"
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  alb_sg_id              = module.networking.alb_sg_id
  app_sg_id              = module.networking.app_sg_id
  db_password            = var.db_password
  db_endpoint            = module.database.db_endpoint
}

module "functions" {
  source       = "./modules/functions"
  project_name = var.project_name
}

module "storage" {
  source       = "./modules/storage"
  project_name = var.project_name
  environment  = var.environment
}

# --- Glue: Route 53 ---
resource "aws_route53_zone" "main" {
  name = "mercadolocalmx.com"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "mercadolocalmx.com"
  type    = "A"

  alias {
    name                   = module.compute.alb_dns_name
    zone_id                = module.compute.alb_zone_id
    evaluate_target_health = true
  }
}

# --- Glue: S3 Trigger Lambda ---
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.functions.lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.storage.bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.storage.bucket_id

  lambda_function {
    lambda_function_arn = module.functions.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }
  
  depends_on = [aws_lambda_permission.allow_bucket]
}
