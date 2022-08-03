#################################################
############ We will create ECR repos ###########
#################################################

resource "aws_ecr_repository" "ecr_lambda" {
  name                 = "lambda"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


############################################
resource "aws_ecs_cluster" "admin_site" {
  name = "admin_site_cluster"
}

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

  container_definitions = jsonencode(
[
  {
    "name": "${var.environment}-boopos-admin",
    "image": "${var.admin_image}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": "80",
        "hostPort": "${var.admin_port}"
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "${var.admin_port}"
      },
      {
        "name": "HEALTHCHECK",
        "value": "${var.health_check_path}"
      },
      {
        "name": "ENABLE_LOGGING",
        "value": "false"
      },
      {
        "name": "PRODUCT",
        "value": "${var.environment}-boopos-admin"
      },
      {
        "name": "ENVIRONMENT",
        "value": "${var.environment}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.environment}-boopos-admin",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
)

}

resource "aws_ecs_service" "admin" {
  name            = "${var.environment}-boopos-admin"
  cluster         = aws_ecs_cluster.admin_site.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.admin.arn
  desired_count   = var.replicas

  network_configuration {
    #count           = length(var.private_admin)

    security_groups = [aws_security_group.allow_all_traffic_from_alb.id]
    subnets         = [aws_subnet.private_admin.*.id[0], aws_subnet.private_admin.*.id[1]]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.admin.id
    container_name   = "${var.environment}-boopos-admin"
    container_port   = var.admin_port
  }
}