terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "tenequm-sc-tfstate"
    # `key` corresponds to file location relatively to Git repository root
    key    = "ops/terraform/live/global/network/tenequm-sc-vpc"
    region = "us-east-1"
  }

  # Required version of Terraform. Allows only the rightmost version component to increment
  required_version = "~> 1.2.6"
}

provider "aws" { region = "eu-west-3" }

variable "vpc_name" {
  default = "tenequm-sc-vpc"
  type    = string
}

variable "associated_cluster_name" {
  default = "tenequm-sc-eks"
  type    = string
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-3a", "eu-west-3b"]
  private_subnets = ["10.0.0.0/18", "10.0.64.0/18"]
  public_subnets  = ["10.0.128.0/18", "10.0.192.0/18"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
      PrivateSubnet = true
      "kubernetes.io/role/internal-elb": 1
  }

  tags = {
    Name      = var.vpc_name
    Terraform = "true"
    "kubernetes.io/cluster/${ var.associated_cluster_name }" = "shared"
  }
}
