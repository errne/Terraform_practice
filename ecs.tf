resource "aws_ecr_repository" "app_repo" {
  name = "my-app-repo"

  tags = {
    Project = "ECS-Example"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "main-cluster"

  tags = {
    Project = "ECS-Example"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "ECS-Example"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "my-app-container"
      image     = "ubuntu:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      command = ["/bin/sh", "-c", "echo 'Hello from my ECS container!' && sleep 3600"]
    }
  ])

  tags = {
    Project = "ECS-Example"
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = ["subnet-ca266182", "subnet-f2bcc894"]
    security_groups = [aws_security_group.allow_tls.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "my-app-container"
    container_port   = 80
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]

  tags = {
    Project = "ECS-Example"
  }
}