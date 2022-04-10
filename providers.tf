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