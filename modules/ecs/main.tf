resource "aws_ecs_cluster" "ecs" {
  name = "${var.name_prefix}-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.task_execution_role

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.container_image
    cpu       = tonumber(var.cpu)
    memory    = tonumber(var.memory)
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
    environment = var.environment_vars
    mountPoints = concat([  # Correct: Mounts reference the volumes defined below
      {
        sourceVolume  = "host-timezone"
        containerPath = "/etc/localtime"
        readOnly      = true
      },
      {
        sourceVolume  = "host-timezone-name"
        containerPath = "/etc/timezone"
        readOnly      = true
      }
    ],
    var.enable_cert_mount ? [  # Only if enabled (backend)
        {
          sourceVolume  = "rds-ca-bundle"
          containerPath = "/etc/ssl/certs/rds-combined-ca-bundle.pem"
          readOnly      = true
        }
      ] : []  # Empty if disabled
    )
  }])

  # Correct: Volumes defined at task level (outside jsonencode)
  volume {
    name      = "host-timezone"
    host_path = "/etc/localtime"
  }

  volume {
    name      = "host-timezone-name"
    host_path = "/etc/timezone"
  }
  dynamic "volume" {
    for_each = var.enable_cert_mount ? [1] : []  # Create only if true
    content {
      name      = "rds-ca-bundle"
      host_path = "/etc/ssl/certs/rds-combined-ca-bundle.pem"
    }
  }

}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.task_family}-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"
  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.security_groups]  # Assuming single ID; make var a list if multiple
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
