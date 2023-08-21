module "fargate-orchestrator-agent" {
  source  = "sysdiglabs/fargate-orchestrator-agent/aws"
  version = "0.3.1"

  vpc_id           = aws_vpc.vpc.id
  subnets          = aws_subnet.public.*.id
  access_key       = var.access_key
  collector_host = var.collector_url
  collector_port = 6443

  name             = "${var.system}-${var.env}-sysdig-orchestrator"
  agent_image      = "quay.io/sysdig/orchestrator-agent:latest"

  # True if the VPC uses an InternetGateway, false otherwise
  assign_public_ip = false

  tags = {
    description    = "Sysdig Serverless Agent Orchestrator"
  }
}
