module "vpc" {
  source                        = "terraform-aws-modules/vpc/aws"
  version                       = "5.1.1"
  name                          = "${var.system}-${var.env}-vpc"
  cidr                          = var.cidr_vpc
  azs                           = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnets               = var.cidr_public
  public_subnets                = var.cidr_private
  enable_nat_gateway            = var.nat_gateway_create
  single_nat_gateway            = var.single_nat_gateways
}