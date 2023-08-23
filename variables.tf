# AWS Region
variable "region" {
  default = "ap-northeast-1"
}

# タスク名などの前につけるプレフィックス(システム名)
variable "system" {
  default = "sysdig"
}

# タスク名などの前につけるプレフィックス(環境名)
variable "env" {
  default = "terraform"
}

# VPCのCIDR
variable "cidr_vpc" {
  default = "10.0.0.0/16"
}

# パブリックサブネットのCIDR
variable "cidr_public" {
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]
}

# プライベートサブネットのCIDR
variable "cidr_private" {
  default = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]
}

# タスクにPublic IPをアサインするか否か。Private Subnetにデプロイする場合はfalseに設定してください
variable "public_ip" {
  default = "false"
}

# NatGatewayの作成有無
variable "nat_gateway_create" {
  default = "true"
}

# NatGatewayをシングル構成で作成するかどうか
variable "single_nat_gateways" {
  default = "true"
}

variable "access_key" {}

variable "secure_api_token" {}

variable "collector_url" {}

variable "sysdig_secure_url" {}