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
terraform apply
```

### 削除
```bash
terraform destroy
```