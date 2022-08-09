resource "aws_efs_file_system" "admin_files" {
  tags = {
    Name          = "${var.environment}-admin-files"
  }
}

resource "aws_efs_mount_target" "admin_files" {
  file_system_id  = aws_efs_file_system.admin_files.id
  subnet_id       = [aws_subnet.private_admin.*.id[0], aws_subnet.private_admin.*.id[1]]
  security_groups = aws_security_group.admin_site_efs.id
  
  tags = {
    Name = "${var.environment}-admin-files"
  }
}
