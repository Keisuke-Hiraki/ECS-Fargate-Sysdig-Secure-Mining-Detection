# ECS-Fargate-Sysdig-Secure-Mining-Detection
「Serverless Agents を利用してECS on Fargate 環境で Sysdig Secure でマイニング検知を実施してみた」ブログのリポジトリです。

## 前提条件
- AWSアカウントを持っていること
- Terraformの実行環境があること
- Sysdig Secureのアカウントを持っていること

## リソース

下記リソースをデプロイします。
- VPC
- Subnet(Public/Private)
- Route Table
- Internet Gateway
- Nat Gateway
- EC2（疑似アタック用サーバ）
- EC2 Instance Connect Endpoint
- Network Load Balancer
- ECS Cluster
  - Sysidig Orchastrator Agent
  - Security Playground（擬似アタック被害コンテナ） + Sysdig Workload Agent

## 構成図

<img src="/image/SysdigSecure-Fargate.png">

## 通信要件

<img src="/image/SysdigSecure-Fargate-Network.png">

## セットアップ手順

### クローン
```bash
git clone https://github.com/Keisuke-Hiraki/ECS-Fargate-Sysdig-Secure-Mining-Detection.git
```

### 初期化
```bash
terraform init
```

### 作成

```bash
terraform apply \
-var 'access_key=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' \
-var 'secure_api_token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' \
-var 'collector_url=xxx.xxx.sysdig.com' \
-var 'sysdig_secure_url=https://xxx.xxx.sysdig.com' 
```

またはterraform.tfvarファイルを作成してください。
```bash:terraform.tfvar
# Sysdig Access key
access_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Sysdig Secure API Token
secure_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# ご自身のSysdig SaaSリージョンの値
collector_url = "xxx.xxx.sysdig.com"

# ご自身のSysdig SaaSリージョンの値
sysdig_secure_url = "https://xxx.xxx.sysdig.com"
```

各パラメータについては下記をご確認ください。
- `access_key` <a href="https://docs.sysdig.com/en/docs/administration/administration-settings/agent-access-keys/" rel="noopener" target="_blank">Agent Access Keys | Sysdig Docs</a>
- `secure_api_token` <a href="https://docs.sysdig.com/en/docs/administration/administration-settings/user-profile-and-password/retrieve-the-sysdig-api-token/" rel="noopener" target="_blank">Retrieve the Sysdig API Token | Sysdig Docs</a>
- `collector_url`と`sysdig_secure_url` <a href="https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges/" rel="noopener" target="_blank">SaaS Regions and IP Ranges | Sysdig Docs</a>

Ex.） US West (Oregon) の場合

`collector_url` は `ingest-us2.app.sysdig.com`

`sysdig_secure_url` は `https://us2.app.sysdig.com`

### 削除

```bash
terraform destroy \
-var 'access_key=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' \
-var 'secure_api_token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' \
-var 'collector_url=xxx.xxx.sysdig.com' \
-var 'sysdig_secure_url=https://xxx.xxx.sysdig.com' 
```

terraform.tfvarファイルを作成していた場合は、

```bash
terraform destroy
```
