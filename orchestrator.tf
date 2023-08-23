module "fargate-orchestrator-agent" {
  source  = "sysdiglabs/fargate-orchestrator-agent/aws"
  version = "0.3.1"

  vpc_id           = module.vpc.vpc_id
  subnets          = var.public_ip ? module.vpc.public_subnets : module.vpc.private_subnets
  access_key       = var.access_key
  collector_host = var.collector_url
  collector_port = 6443

  name             = "${var.system}-${var.env}-sysdig-orchestrator"
  agent_image      = "quay.io/sysdig/orchestrator-agent:latest"

  # True if the VPC uses an InternetGateway, false otherwise
  assign_public_ip = var.public_ip

  tags = {
    description    = "Sysdig Serverless Agent Orchestrator"
  }
}
