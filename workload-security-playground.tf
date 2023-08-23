data "sysdig_fargate_workload_agent" "containers_instrumented" {
  container_definitions = jsonencode([
    {
      "name" : "security-playground",
      "image" : "sysdiglabs/security-playground",
      "cpu": 1024,
      "memory": 2048,
      "command" : ["gunicorn", "-b", ":8080", "--workers", "2", "--threads", "4", "--worker-class", "gthread", "--access-logfile", "-", "--error-logfile", "-", "app:app"],
      "environment": [
        {
          "name": "SYSDIG_ENABLE_LOG_FORWARD",
          "value": "false"
        },
        {
          "name": "SYSDIG_LOGGING",
          "value": "debug"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : aws_cloudwatch_log_group.instrumented_logs.name,
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "ecs-${var.system}-${var.env}-"
        },
      }
    }
  ])

  workload_agent_image = "quay.io/sysdig/workload-agent:latest"

  sysdig_access_key = var.access_key
  orchestrator_host = module.fargate-orchestrator-agent.orchestrator_host
  orchestrator_port = module.fargate-orchestrator-agent.orchestrator_port
}

resource "aws_ecs_task_definition" "task_definition" {
  family             = "${var.system}-${var.env}-instrumented-task-definition"
  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.execution_role.arn

  cpu                      = "1024"
  memory                   = "2048"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = data.sysdig_fargate_workload_agent.containers_instrumented.output_container_definitions
}


resource "aws_ecs_cluster" "cluster" {
  name = "${var.system}-${var.env}-fargate-instrumented-workload"
}

resource "aws_cloudwatch_log_group" "instrumented_logs" {
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role" "task_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  inline_policy {
    name   = "root"
    policy = data.aws_iam_policy_document.task_policy.json
  }
}

data "aws_iam_policy_document" "task_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_role_ssmmessages" {
  version = "2012-10-17"
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_role_ssmmessages" {
  name_prefix = "${var.system}-${var.env}-ecs_task-ssmmessages"
  policy = data.aws_iam_policy_document.ecs_task_role_ssmmessages.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ssmmessages" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_ssmmessages.arn
}

resource "aws_ecs_service" "service" {
  name = "${var.system}-${var.env}-instrumented-service"

  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.task_definition.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  enable_execute_command = true

  network_configuration {
    subnets          = [for s in aws_subnet.private.*.id : s]
    security_groups  = [aws_security_group.security_group.id]
    assign_public_ip = var.public_ip
  }
}

resource "aws_security_group" "security_group" {
  description = "test only"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "security_playground_ingress_rule" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_blocks       = ["${aws_instance.bastion_ec2.private_ip}/32"]
  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "orchestrator_agent_egress_rule" {
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group.id
}

