
resource "aws_security_group" "vpc_endpoint_sg" {
  name_prefix      = "vpc-endpoint-"
  vpc_id      = data.aws_vpc.default.id
  description = "security group for accessing VPC endpoints"
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${local.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpc_endpoint_sg.id,
  ]
}

resource "aws_vpc_endpoint_subnet_association" "secrets_manager" {
  count = length(data.aws_subnets.all.ids)

  vpc_endpoint_id = aws_vpc_endpoint.secrets_manager.id
  subnet_id       = data.aws_subnets.all.ids[count.index]
}

resource "aws_security_group" "setup_lambda_sg" {
  name_prefix = "setup-lambda-"
  vpc_id      = data.aws_vpc.default.id
  description = "security group for the setup lambda"
}

resource "aws_security_group_rule" "setup_lambda_to_vpc_endpoint" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.setup_lambda_sg.id
  source_security_group_id = aws_security_group.vpc_endpoint_sg.id
}

resource "aws_security_group_rule" "vpc_endpoint_allow_setup_lambda" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.setup_lambda_sg.id
  security_group_id        = aws_security_group.vpc_endpoint_sg.id
}