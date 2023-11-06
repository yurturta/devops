#data "aws_availability_zones" "available" {
#  state = "available"
#}

locals {
  cluster_name = "eks-terraform"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

#  env_code = "Prague"
#  vpc_cidr = "10.0.0.0/16"
#  public_cidr = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
#  private_cidr = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
#  availability_zones = data.aws_availability_zones.available.names

  azs               = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets   = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
  public_subnets    = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

}