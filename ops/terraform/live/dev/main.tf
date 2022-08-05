terraform {
  backend "s3" {
    bucket = "tenequm-sc-tfstate"
    # `key` corresponds to file location relatively to Git repository root
    key      = "ops/terraform/live/dev"
    region   = "us-east-1"
    encrypt  = true
    role_arn = "arn:aws:iam::835985159754:role/terraform-role"
  }
  required_version = ">= 1.2.6"
}

provider "aws" {
  region = "eu-west-3"
  assume_role { role_arn = "arn:aws:iam::835985159754:role/terraform-role" }
  default_tags { tags = { Terraform = "true" } }
}

data "aws_eks_cluster" "cluster" { name = "tenequm-sc-eks" }
data "aws_eks_cluster_auth" "cluster" { name = "tenequm-sc-eks" }
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace" "default" {
  metadata {
    name   = "dev"
    labels = { monitoring : "true" }
  }
}