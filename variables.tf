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

# NatGatewayの作成有無
variable "nat_gateway_create" {
  default = "false"
}

# NatGatewayを作成する場合の台数
variable "nat_gateways_count" {
  default = 0
}

# Sysdig Access key
variable "access_key" {
  default = "82e62c0e-8e2a-4e5c-986e-38cd116f3151"
}

# Sysdig Secure API Token
variable "secure_api_token" {
  default = "01f0c6e7-010b-4cb2-a1e6-99cd40afa43e"
}

# ご自身のSysdig SaaSリージョンの値を入力してください
variable "collector_url" {
  default = "ingest.au1.sysdig.com"
}

# ご自身のSysdig SaaSリージョンの値を入力してください
variable "sysdig_secure_url" {
  default = "https://app.au1.sysdig.com"
}

# Curlコマンドを打って疑似アタックを実行する端末のIPアドレスを入力してください
# このIPアドレスからWorkloadタスクに対する8080ポート接続を許可するSecurity Group設定を作成します
variable "source_ip" {
  default = "10.0.10.233/32"
}