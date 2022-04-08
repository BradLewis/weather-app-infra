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
  region = "us-east-1"
}

locals {
  name = "weather-app"
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

module "weather_app_aurora_mysql" {
  source = "github.com/terraform-aws-modules/terraform-aws-rds-aurora?ref=v3.5.0"

  name              = "${local.name}-mysql"
  engine            = "aurora-mysql"
  engine_mode       = "serverless"
  engine_version    = "5.7.mysql_aurora.2.07.1"
  storage_encrypted = true

  subnets               = data.aws_subnets.all.ids
  vpc_id                = data.aws_vpc.default.id
  create_security_group = true

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.example_mysql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example_mysql.id

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 1
    max_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}

resource "aws_db_parameter_group" "example_mysql" {
  name        = "${local.name}-aurora-db-mysql-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-db-mysql-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example_mysql" {
  name        = "${local.name}-aurora-mysql-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-mysql-cluster-parameter-group"
}