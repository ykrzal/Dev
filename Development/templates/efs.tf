resource "aws_efs_file_system" "admin_files" {
  tags = {
    Name          = "${var.environment}-admin-files"
  }
}

resource "aws_efs_mount_target" "admin_files" {
  count               = length(var.private_admin)
  
  file_system_id  = aws_efs_file_system.admin_files.id
  subnet_id       = element(aws_subnet.private_admin.*.id,count.index)
  security_groups = [aws_security_group.admin_site_efs.id]
  
}

resource "aws_efs_access_point" "admin_blue" {
  file_system_id = aws_efs_file_system.admin_files.id

  root_directory {
    path = "/blue"
  }
}

resource "aws_efs_access_point" "admin_green" {
  file_system_id = aws_efs_file_system.admin_files.id

  root_directory {
    path = "/green"
  }
}