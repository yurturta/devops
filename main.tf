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

resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = module.vpc.public_subnets
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "cluster" {
  name                      = "${local.cluster_name}-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "Everything" {
  policy_arn = "arn:aws:iam::751848563850:policy/GeneratedPolicy-20231017162310-fus-1-1"
  role       = aws_iam_role.cluster.name
}
