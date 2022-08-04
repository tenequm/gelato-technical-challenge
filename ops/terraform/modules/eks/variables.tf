variable "cluster_name" {
  description = "Name of the EKS cluster"
}

variable "vpc_name" {
  description = "Name of the VPC where EKS cluster will be located"
}

variable "node_groups" {
  default = {}
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "cluster_enabled_log_types" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
}

variable "worker_ssh_public_key" {
  description = "SSH key for connecting to Worker nodes"
  default     = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAEGmR3yntCg5CJCks56sqA0H266vpWUmxFkamZ1dsauMPksft+WMSd4KqxuHiQUZG6OrNra+82KQ2KBL8PRQWqDFgHVXS7GAJfjT4D9ohzfRlCfnCa1293fd4MyrDRhBWbu2W3fLh3dFU+DDRJeijceO/E4/9qlRiIFLkyVK7Jfwe9Lzw== devops@byteant.com"
}

variable "eks_cluster_version" {
  description = "EKS cluster version"
  default     = "1.22"
}

variable "k8s_service_account_namespace" {
  description = "EKS service account namespace"
  default     = "kube-system"
}

variable "manage_aws_auth" {
  description = "Whether to apply the aws-auth configmap file."
  default     = "true"
}
