#################################################
############ We will create ECR repos ###########
#################################################

# resource "aws_ecr_repository" "ecr_lambda" {
#   name                 = "lambda"
#   image_tag_mutability = "IMMUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

#################################################
######## AWS ECS CLuster for Admin site #########
#################################################


resource "aws_ecs_cluster" "admin_site" {
  name = "admin_site_cluster"
}


#################################################
####### Admin Blue on port 8080 #################
#################################################

resource "aws_appautoscaling_target" "admin_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.admin_site.name}/${aws_ecs_service.admin.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.admin_ecs_max_instances
  min_capacity       = var.admin_ecs_min_instances
}

resource "aws_ecs_task_definition" "admin" {
  family                   = "${var.environment}-boopos-admin"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.admin_cpu
  memory                   = var.admin_memory
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn

  #task_role_arn = aws_iam_role.admin_role.arn
  task_role_arn = aws_iam_role.ecs_tasks_execution_role.arn

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "${var.environment}-boopos-admin",
    "image": "${var.admin_image}",
    "essential": true,
    "mountPoints": [
          {
              "containerPath": "/usr/share/nginx/html",
              "sourceVolume": "admin-efs"
          }
      ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${jsonencode(var.admin_container_port)},
        "hostPort": ${jsonencode(var.admin_container_port)}
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "${var.admin_port}"
      },
      {
        "name": "ENVIRONMENT",
        "value": "${var.environment}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group": "true",
        "awslogs-group": "/fargate/service/${var.environment}-boopos-admin",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION
  volume {
      name                = "admin-efs"
      efs_volume_configuration {
        file_system_id    = aws_efs_file_system.admin_files.id
        root_directory    = "/"
      }
    }
}

resource "aws_ecs_service" "admin" {
  name                    = "${var.environment}-boopos-admin"
  cluster                 = aws_ecs_cluster.admin_site.id
  launch_type             = "FARGATE"
  task_definition         = aws_ecs_task_definition.admin.arn
  desired_count           = var.replicas

  network_configuration {
    security_groups       = [aws_security_group.allow_all_traffic_from_alb.id]
    subnets               = [aws_subnet.private_admin.*.id[0], aws_subnet.private_admin.*.id[1]]
  }

  load_balancer {
    target_group_arn      = aws_alb_target_group.admin.id
    container_name        = "${var.environment}-boopos-admin"
    container_port        = var.admin_container_port
  }
}

##################################################
####### Admin Green on port 8080 #################
##################################################
resource "aws_appautoscaling_target" "admin_gree_scale_target" {
  service_namespace        = "ecs"
  resource_id              = "service/${aws_ecs_cluster.admin_site.name}/${aws_ecs_service.admin_green.name}"
  scalable_dimension       = "ecs:service:DesiredCount"
  max_capacity             = var.admin_ecs_max_instances
  min_capacity             = var.admin_ecs_min_instances
}

resource "aws_ecs_task_definition" "admin_green" {
  family                   = "${var.environment}-boopos-admin-green"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.admin_cpu
  memory                   = var.admin_memory
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_tasks_execution_role.arn

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "${var.environment}-boopos-admin-green",
    "image": "${var.admin_image}",
    "essential": true,
    "mountPoints": [
          {
              "containerPath": "/usr/share/nginx/html",
              "sourceVolume": "admin-efs"
          }
      ],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${jsonencode(var.admin_container_port)},
        "hostPort": ${jsonencode(var.admin_container_port)}
      }
    ],
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "${var.environment}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group": "true",
        "awslogs-group": "/fargate/service/${var.environment}-boopos-admin-green",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION
  volume {
      name      = "admin-efs"
      efs_volume_configuration {
        file_system_id = aws_efs_file_system.admin_files.id
        root_directory = "/green"
      }
    }
}

resource "aws_ecs_service" "admin_green" {
  name            = "${var.environment}-boopos-admin-green"
  cluster         = aws_ecs_cluster.admin_site.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.admin_green.arn
  desired_count   = var.replicas

  network_configuration {
    security_groups = [aws_security_group.allow_all_traffic_from_alb.id]
    subnets         = [aws_subnet.private_admin.*.id[0], aws_subnet.private_admin.*.id[1]]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.admin_green.id
    container_name   = "${var.environment}-boopos-admin-green"
    container_port   = var.admin_container_port
  }
}


