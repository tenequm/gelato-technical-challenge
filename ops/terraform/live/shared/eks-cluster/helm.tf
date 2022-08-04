resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "6.0.10"
}

resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.3"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::835985159754:role/aws-load-balancer-controller"
  }
}

# External DNS setup
# CLOUDFLARE_API_TOKEN params is stored in 835985159754 AWS account Parameter Store
data "aws_ssm_parameter" "cloudflare-api-token" {
  name = "CLOUDFLARE_API_TOKEN"
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "6.7.4"

  set {
    name  = "provider"
    value = "cloudflare"
  }
  set_sensitive {
    name  = "cloudflare.apiToken"
    value = data.aws_ssm_parameter.cloudflare-api-token.value
  }
  set {
    name  = "domainFilters[0]"
    value = "tenequm-sc.tk"
  }
  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }
  set {
    name  = "txtPrefix"
    value = "external-dns."
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::835985159754:role/${var.cluster_name}-aws-eks-external-dns"
  }
}