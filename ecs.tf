# ecs.tf

# 1. ECR Repository to store the Docker image
resource "aws_ecr_repository" "app_repo" {
  name = "my-app-repo" # Choose a name for your repository

  tags = {
    Project = "ECS-Example"
  }
}

# 2. ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "main-cluster"

  tags = {
    Project = "ECS-Example"
  }
}

# 3. IAM Role for ECS Task Execution
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

# 4. ECS Task Definition
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
      # IMPORTANT: Replace this with the URI of your actual image in ECR
      # After creating the ECR repo, push your image and update this line.
      # Example: "${aws_ecr_repository.app_repo.repository_url}:latest"
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
      # The command that the container will run. For this ubuntu image,
      # it will print a message and exit. Replace with your application's command.
      command = ["/bin/sh", "-c", "echo 'Hello from my ECS container!' && sleep 3600"]
    }
  ])

  tags = {
    Project = "ECS-Example"
  }
}

# 5. ECS Service
resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    # IMPORTANT: Replace with your VPC's subnets and a security group
    subnets         = ["subnet-ca266182", "subnet-f2bcc894"] # Example subnets, replace with yours
    security_groups = [aws_security_group.allow_tls.id]      # Example security group, replace with yours
    assign_public_ip = true
  }

  # Optional: Add a load balancer
  # load_balancer {
  #   target_group_arn = aws_lb_target_group.app_tg.arn
  #   container_name   = "my-app-container"
  #   container_port   = 80
  # }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]

  tags = {
    Project = "ECS-Example"
  }
}
