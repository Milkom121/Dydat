# --- infra/eks.tf ---

# 1. IAM Role for EKS Cluster Control Plane
resource "aws_iam_role" "eks_cluster_role" {
  name = "dydat-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# 2. IAM Role for EKS Worker Nodes
resource "aws_iam_role" "eks_node_group_role" {
  name = "dydat-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# 3. EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "dydat-main-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.default.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
  ]
}

# 4. EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "dydat-main-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.ecr_read_only_policy_attachment,
  ]
} 