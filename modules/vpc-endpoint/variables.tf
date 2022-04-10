variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "vpc_endpoint_type" {
  type = string
}

variable "private_dns_enabled" {
  type = bool
}

variable "vpc_endpoint_sg_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allowed_security_group_ids" {
  type = list(string)
}