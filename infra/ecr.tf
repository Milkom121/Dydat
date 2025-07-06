# --- infra/ecr.tf ---

# 1. ECR Repository for the Backend application
resource "aws_ecr_repository" "backend" {
  name                 = "dydat/backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 2. ECR Repository for the Frontend application
resource "aws_ecr_repository" "frontend" {
  name                 = "dydat/frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# --- Outputs ---
output "backend_ecr_url" {
  description = "The URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_url" {
  description = "The URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
} 