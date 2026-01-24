
module "waf" {
  source       = "./modules/security/waf"
  project_name = var.project_name
  environment  = var.environment
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = module.compute.alb_arn
  web_acl_arn  = module.waf.web_acl_arn
}
