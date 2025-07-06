# --- infra/auth.tf ---

# 1. Get EKS Cluster Info for Kubernetes Provider
data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.main.name
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

data "aws_caller_identity" "current" {}

# 2. Configure Kubernetes Provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token
}

# 3. Create/Manage the aws-auth ConfigMap
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  
  data = {
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Cursor"
        username = "Cursor"
        groups   = ["system:masters"]
      }
    ])
  }

  force = true # Allows Terraform to overwrite the existing ConfigMap
} 