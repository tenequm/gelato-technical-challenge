terraform {
  backend "s3" {
    bucket = "tenequm-sc-tfstate"
    # `key` corresponds to file location relatively to Git repository root
    key      = "ops/terraform/live/shared/rds"
    region   = "us-east-1"
    encrypt  = true
    role_arn = "arn:aws:iam::835985159754:role/terraform-role"
  }
  required_version = ">= 1.2.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
provider "aws" {
  region = "eu-west-3"
  assume_role { role_arn = "arn:aws:iam::835985159754:role/terraform-role" }
  default_tags { tags = { Terraform = "true" } }
}

locals {
  vpc_id             = "vpc-0bdb30e027884aaf4"
  vpc_cidr_blocks    = ["10.0.0.0/8"]
  es_domain_name     = "tenequm-sc"
}
data "aws_ssm_parameter" "rds_password" { name = "RDS_POSTGRESQL_MASTER_PASSWORD" }

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  tags = { PrivateSubnet = true }
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "4.9.0"

  name                = "tenequm-sc-postgres"
  description         = "tenequm-sc PostgreSQL security group"
  vpc_id              = local.vpc_id
  ingress_cidr_blocks = local.vpc_cidr_blocks
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.0.1"

  identifier = "tenequm-sc-postgres"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "13.4"
  family               = "postgres13" # DB parameter group
  major_engine_version = "13"         # DB option group
  instance_class       = "db.t3.micro"
  apply_immediately    = true #	Specifies whether any database modifications are applied immediately, or during the next maintenance window

  allocated_storage     = 10
  max_allocated_storage = 100
  storage_encrypted     = true
  storage_type          = "gp2"

  name                                = "tenequm-sc"
  username                            = "tenequm-sc"
  password                            = data.aws_ssm_parameter.rds_password.value
  port                                = 5432
  iam_database_authentication_enabled = true

  multi_az               = false
  subnet_ids             = data.aws_subnets.private.*.ids
  vpc_security_group_ids = [module.db_sg.security_group_id]

  # That's Mon:00:00-Mon:03:00 EST (Miami time)
  maintenance_window = "Mon:05:00-Mon:08:00"
  # That's Mon:03:00-Mon:06:00 EST (Miami time)
  backup_window                   = "08:00-11:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 35
  skip_final_snapshot     = false
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "tenequm-sc-rds-monitoring-role"
  monitoring_role_description           = "Role for RDS PostgreSQL monitoring needs"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    }
  ]
}
