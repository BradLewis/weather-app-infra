terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.9.0"
    }
  }
  cloud {
    organization = "bradlewis"

    workspaces {
      name = "weather-app-infra"
    }
  }
}
provider "aws" {
  region = local.region
}

locals {
  name   = "weather-app"
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.default.id
    ]
  }
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${local.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.setup_lambda_sg.id,
  ]
}

resource "aws_security_group" "setup_lambda_sg" {
  name_prefix = "setup-lambda-"
  vpc_id      = data.aws_vpc.default.id
  description = "security group for the setup lambda"
}

module "weather_app_aurora_mysql" {
  source = "github.com/terraform-aws-modules/terraform-aws-rds-aurora?ref=v6.2.0"

  name              = "${local.name}-mysql"
  engine            = "aurora-mysql"
  engine_mode       = "serverless"
  engine_version    = "5.7.mysql_aurora.2.07.1"
  storage_encrypted = true

  subnets               = data.aws_subnets.all.ids
  vpc_id                = data.aws_vpc.default.id
  create_security_group = true

  allowed_security_groups = [
    aws_security_group.setup_lambda_sg.id
  ]

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 1
    max_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}

resource "aws_secretsmanager_secret" "weather_app_db_credentials" {
  name = "${local.name}-aurora-db-master-credentials"
}

resource "aws_secretsmanager_secret_version" "weather_app_db_credentials" {
  secret_id = aws_secretsmanager_secret.weather_app_db_credentials.id
  secret_string = jsonencode(
    {
      username = module.weather_app_aurora_mysql.cluster_master_username
      password = module.weather_app_aurora_mysql.cluster_master_password
      host     = module.weather_app_aurora_mysql.cluster_endpoint
    }
  )
}