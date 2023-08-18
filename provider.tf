provider "aws" {
  region = "${var.region}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0"
    }
    sysdig = {
      source = "sysdiglabs/sysdig"
      version = ">= 0.5.39"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url       = "${var.sysdig_secure_url}"
  sysdig_secure_api_token = "${var.secure_api_token}"
}