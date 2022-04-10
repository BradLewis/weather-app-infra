
resource "aws_security_group" "vpc_endpoint_sg" {
  name_prefix = "vpc-endpoint-"
  vpc_id      = data.aws_vpc.default.id
  description = "security group for accessing VPC endpoints"
  tags = {
    Name = "vpc-endpoint"
  }
}

resource "aws_security_group" "setup_lambda_sg" {
  name_prefix = "setup-lambda-"
  vpc_id      = data.aws_vpc.default.id
  description = "security group for the setup lambda"
  tags = {
    Name = "setup-lambda"
  }
}

module "secretsmanager_vpc_endpoint" {
  source = "./modules/vpc-endpoint"

  region              = local.region
  vpc_id              = data.aws_vpc.default.id
  service_name        = "secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_endpoint_sg_id  = aws_security_group.vpc_endpoint_sg.id
  subnet_ids          = data.aws_subnets.all.ids

  allowed_security_group_ids = [
    aws_security_group.setup_lambda_sg.id
  ]
}