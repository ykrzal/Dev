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

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/blue"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
}

resource "aws_efs_access_point" "admin_green" {
  file_system_id = aws_efs_file_system.admin_files.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/green"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.admin_files.id

  bypass_policy_lockout_safety_check = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleStatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.test.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}