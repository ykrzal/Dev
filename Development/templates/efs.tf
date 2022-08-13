#### We create EFS #####

resource "aws_efs_file_system" "admin_files" {
  tags = {
    Name            = "${var.environment}-admin-files"
  }
}

resource "aws_efs_file_system" "admin_files_green" {
  tags = {
    Name            = "${var.environment}-admin-files-green"
  }
}

resource "aws_efs_mount_target" "admin_files" {
  count             = length(var.private_admin)
  
  file_system_id    = aws_efs_file_system.admin_files.id
  subnet_id         = element(aws_subnet.private_admin.*.id,count.index)
  security_groups   = [aws_security_group.admin_site_efs.id]
  
}

resource "aws_efs_mount_target" "admin_files_green" {
  count             = length(var.private_admin)
  
  file_system_id    = aws_efs_file_system.admin_files_green.id
  subnet_id         = element(aws_subnet.private_admin.*.id,count.index)
  security_groups   = [aws_security_group.admin_site_efs.id]
  
}