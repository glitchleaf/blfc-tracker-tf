resource "random_pet" "db_user" {
  separator = "_"
}

resource "random_password" "db_password" {
  length  = 50
  special = false
}

resource "aws_rds_cluster" "tracker" {
  cluster_identifier     = "tracker"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = "16.4"
  database_name          = "tracker"
  deletion_protection    = true
  copy_tags_to_snapshot  = true
  db_subnet_group_name   = aws_db_subnet_group.private.name
  kms_key_id             = aws_kms_key.tracker.arn
  master_password        = random_password.db_password.result
  master_username        = random_pet.db_user.id
  storage_encrypted      = true
  vpc_security_group_ids = [aws_security_group.postgres_tracker.id]

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "tracker" {
  cluster_identifier              = aws_rds_cluster.tracker.id
  auto_minor_version_upgrade      = true
  db_subnet_group_name            = aws_db_subnet_group.private.name
  engine                          = aws_rds_cluster.tracker.engine
  engine_version                  = aws_rds_cluster.tracker.engine_version
  instance_class                  = "db.serverless"
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.tracker.arn
}

resource "aws_security_group" "postgres_tracker" {
  name        = "postgres-tracker"
  description = "Allow Tracker to talk to postgres"
  vpc_id      = data.aws_vpc.resolved.id
}

resource "aws_vpc_security_group_ingress_rule" "postgres_tracker" {
  security_group_id            = aws_security_group.postgres_tracker.id
  description                  = "Allow Tracker to talk to us"
  from_port                    = aws_rds_cluster.tracker.port
  to_port                      = aws_rds_cluster.tracker.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.tracker.id
}

resource "aws_db_subnet_group" "private" {
  name       = "private"
  subnet_ids = data.aws_subnets.private.ids
}
