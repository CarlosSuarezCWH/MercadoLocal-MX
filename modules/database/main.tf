resource "aws_db_subnet_group" "default" {
  name       = lower("${var.project_name}-db-subnet-group")
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  identifier        = lower("${var.project_name}-db")
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  db_name           = "wordpress"
  username          = "admin"
  password          = var.db_password
  
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot    = true # For demo/dev purposes

  tags = {
    Name = "${var.project_name}-rds"
  }
}
