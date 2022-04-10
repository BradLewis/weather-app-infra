
resource "aws_vpc_endpoint" "this" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${var.service_name}"
  vpc_endpoint_type   = var.vpc_endpoint_type
  private_dns_enabled = var.private_dns_enabled

  security_group_ids = [
    var.vpc_endpoint_sg_id,
  ]
}

resource "aws_vpc_endpoint_subnet_association" "this" {
  count = length(var.subnet_ids)

  vpc_endpoint_id = aws_vpc_endpoint.this.id
  subnet_id       = var.subnet_ids[count.index]
}

resource "aws_security_group_rule" "allowed_to_vpc_endpoint" {
  count = length(var.allowed_security_group_ids)

  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.allowed_security_group_ids[count.index]
  source_security_group_id = var.vpc_endpoint_sg_id
}

resource "aws_security_group_rule" "vpc_endpoint_to_allowed" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.vpc_endpoint_sg_id
  source_security_group_id = var.allowed_security_group_ids[count.index]
}