terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.2.6"
}

resource "aws_key_pair" "eks-worker-key" {
  key_name   = "eks-worker-key"
  public_key = var.worker_ssh_public_key
}

resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
  policy      = data.aws_iam_policy_document.ebs_decryption.json
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_version = var.eks_cluster_version
  vpc_id          = data.aws_vpc.selected.id
  cluster_name    = var.cluster_name
  subnets         = flatten(data.aws_subnets.private.*.ids)

  cluster_enabled_log_types = var.cluster_enabled_log_types

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  node_groups_defaults = {
    ami_type = "AL2_x86_64"

    create_launch_template = true

    root_encrypted  = true
    disk_encrypted  = true
    disk_kms_key_id = aws_kms_key.eks.arn

    disk_size = 100
    disk_type = "gp3"

    key_name = aws_key_pair.eks-worker-key.key_name

    enable_monitoring = true
  }

  enable_irsa = true

  node_groups = var.node_groups

  worker_additional_security_group_ids = [aws_security_group.eks_mgmt.id]

  manage_aws_auth = var.manage_aws_auth
  map_roles       = var.map_roles
  map_users       = var.map_users
}


# Monitoring related resources
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name   = "monitoring"
    labels = { monitoring : "true" }
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "tenequm-sc-eks-loki-logs-storage"
  acl    = "private"

  lifecycle_rule {
    id      = "log_rotation"
    enabled = true
    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    expiration { days = 90 }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default { sse_algorithm = "aws:kms" }
    }
  }
}