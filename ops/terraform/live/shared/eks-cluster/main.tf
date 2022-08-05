terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
  }

  backend "s3" {
    bucket = "tenequm-sc-tfstate"
    # `key` corresponds to file location relatively to Git repository root
    key      = "ops/terraform/live/shared/eks-cluster"
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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

variable "cluster_name" {
  default = "tenequm-sc-eks"
}

variable "vpc_name" {
  default = "tenequm-sc-vpc"

}

module "eks_cluster" {
  source       = "../../../modules/eks"
  cluster_name = var.cluster_name
  vpc_name     = var.vpc_name
  map_roles = [
    {
      rolearn  = "arn:aws:iam::835985159754:role/terraform-role"
      username = "terraform:{{SessionName}}"
      groups   = ["system:masters"]
    }
  ]
  map_users = [
    {
      userarn  = "arn:aws:iam::835985159754:user/admin-user"
      username = "admin-user"
      groups   = ["system:masters"]
    }
  ]
  node_groups = {
    main_ng = {
      name = "${var.cluster_name}-main-ng"

      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2

      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }

  # Private Key is stored in AWS Systems Manager Parameter Store 
  # and is called `tenequm-sc-eks-ssh-worker-private-key`
  worker_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClq8L0VUjn65U3GWTdjZH5kXDSAu5RCVm2rpcho8qeevDBmI0lkbD5JjCTiWDmHiWIXvQvaSIF3HUs4ycQb0sOVq30TtVdzacOCQyq498QF+tcgQOb17VooGNs6lkm/JM67dDYubNZKisEnUvbFqzIiZXKwwNLScQRAw/fx2YjgN/iw7Q3f9gw+H+vPHxOPlUpwBrqPQH+RNmYU25PL9ApKFiVZ0n2WgsPI7DArnbGRlZhIB+2xnErWwEB2Y0CnQgT5aXMHUgcnn6pvWtf/DeHarCFmBEBBs8vcbJH+WBFwBzTms7k2p0ss3pBq+VvDNsGoVCbxShrsBqq/InQeoHMmlUxzgjrHf0MjwA2S3xVoomod9erqWvivbT3tYf/4GCvKYVstWNVn9lIop7NbNytYvmVKt+ckvI9zuz5zBRm+EXB3utWIxmiW99J2D35OAmHZb0O0heGCLvJtHwaWg7nW+qdmq0EKWL+Uud4qtOxyvmjEfhFOEqcciDe1MO/s5flPrYnDoxYaU6ADRg7Xnkkuu8VMWqMMQK6EbFVFY/ESHLN+oKTOfSnfgkMH+lMLsGOKdfnO055nV10Nr0f3gHR/TxcdB98/L4jgE7Q+cUd6gmzKe94XbC54QSSJB5IldZqDhEZA5K1W2XaALfLshJofrGeb8PLSddVcJJwqTleIQ=="
  eks_cluster_version   = "1.22"
}