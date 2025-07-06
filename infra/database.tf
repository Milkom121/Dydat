# --- infra/database.tf ---

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

resource "aws_rds_cluster" "dydat_cluster" {
  cluster_identifier      = "dydat-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = "15.3" # Aurora usa versioni specifiche, proviamo con questa
  database_name           = "dydatdb"
  master_username         = "dydatadmin"
  manage_master_user_password = true # Lasciamo che AWS gestisca la password
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.default.id]
}

resource "aws_rds_cluster_instance" "dydat_cluster_instance" {
  cluster_identifier = aws_rds_cluster.dydat_cluster.id
  instance_class     = "db.t3.medium" # Aurora richiede classi di istanza diverse
  engine             = aws_rds_cluster.dydat_cluster.engine
  engine_version     = aws_rds_cluster.dydat_cluster.engine_version
}

resource "aws_db_subnet_group" "default" {
  name       = "dydat-main-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "Dydat DB Subnet Group"
  }
}

# Questo subnet group lo abbiamo già definito ma lo tengo qui per riferimento logico
# resource "aws_db_subnet_group" "default" {
#   name       = "dydat-main-subnet-group"
#   subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
# }

output "db_cluster_secret_arn" {
  description = "The ARN of the secret containing the database credentials"
  value       = aws_rds_cluster.dydat_cluster.master_user_secret[0].secret_arn
} 