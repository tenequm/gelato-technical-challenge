module "iam_assumable_role_aws_eks_load_balancer_controller" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.2.0"
  create_role                   = true
  role_name                     = "aws-load-balancer-controller"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_eks_load_balancer_controller_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_service_account_namespace}:aws-load-balancer-controller"]
}

module "iam_assumable_role_aws_eks_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.2.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-aws-eks-external-dns"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_eks_route53_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_service_account_namespace}:external-dns"]
}

module "iam_assumable_role_eks_monitoring" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.2.0"
  create_role  = true
  role_name    = "eks-monitoring"
  provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
    aws_iam_policy.monitoring_access.arn
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:eks-monitoring"]
}


resource "aws_iam_policy" "aws_eks_load_balancer_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "EKS LB Controller Policy"
  policy      = file("${path.module}/irsa-iam-policy.json")
}

resource "aws_iam_policy" "aws_eks_route53_policy" {
  description = "Allow to update our zone"
  name        = "${var.cluster_name}-aws-eks-route53-policy"
  policy      = data.aws_iam_policy_document.allow_external_dns_updates.json
}

resource "aws_iam_policy" "monitoring_access" {
  name        = "monitoring_access"
  description = "Policy that provides permissions for monitoring tools running in EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.logs.arn}",
          "${aws_s3_bucket.logs.arn}/*"
        ]
      },
    ]
  })
}
