resource "aws_efs_file_system" "main" {
  creation_token   = "${var.project_name}-${var.environment}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic" # Key for high performance/scale

  tags = {
    Name = "${var.project_name}-${var.environment}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.private_app_subnets)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_app_subnets[count.index]
  security_groups = [var.security_group_id]
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.main.id

  backup_policy {
    status = "ENABLED"
  }
}
