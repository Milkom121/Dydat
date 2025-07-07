# --- infra/database.tf ---

resource "aws_security_group" "db_sg" {
  name        = "dydat-db-sg-v2"
  description = "Allow traffic to the database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }
}

resource "aws_rds_cluster" "dydat_db" {
  cluster_identifier          = "dydat-db-cluster-v3"
  engine                      = "aurora-postgresql"
  engine_version              = "16.1"
  database_name               = "dydat"
  master_username             = "dydatadmin"
  manage_master_user_password = true
  skip_final_snapshot         = true
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  db_subnet_group_name        = aws_db_subnet_group.default.name
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                       = 1
  identifier                  = "dydat-db-cluster-instance-v3-${count.index}"
  cluster_identifier          = aws_rds_cluster.dydat_db.id
  instance_class              = "db.t3.medium"
  engine                      = aws_rds_cluster.dydat_db.engine
  engine_version              = aws_rds_cluster.dydat_db.engine_version
}

resource "aws_db_subnet_group" "default" {
  name       = "dydat-db-subnet-group-v2"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "Dydat DB subnet group"
  }
}

output "db_cluster_secret_arn" {
  description = "The ARN of the secret containing the database credentials"
  value       = aws_rds_cluster.dydat_db.master_user_secret[0].secret_arn
  sensitive   = true
}

output "db_cluster_endpoint" {
  description = "The endpoint of the database cluster"
  value       = aws_rds_cluster.dydat_db.endpoint
} 