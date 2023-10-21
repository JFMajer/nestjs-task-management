#############################################
# VPC                                       #
#############################################

//noinspection MissingModule
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  azs = local.azs

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true

  name = "${var.app_name}-vpc-#{ENV}#"
  cidr = var.vpc_cidr

  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)]

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
    "karpenter.sh/discovery"                    = var.cluster_name
  }
}

#############################################
# VPC Endpoint for SSM and SSM Messages     #
#############################################

resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id             = module.vpc.vpc_id
  for_each           = local.endpoints
  service_name       = "com.amazonaws.#{AWS_REGION}#.${each.value.name}"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.ssm.id]
  subnet_ids         = module.vpc.private_subnets
}

resource "aws_security_group" "ssm" {
  name        = "${var.app_name}-ssm-#{ENV}#"
  description = "Security group for SSM"

  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow SSM traffic from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}