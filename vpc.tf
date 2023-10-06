data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  env_code = "Prague"
  vpc_cidr = "10.0.0.0/16"
  public_cidr = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_cidr = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
  availability_zones = data.aws_availability_zones.available.names

}