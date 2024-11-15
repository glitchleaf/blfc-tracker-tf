resource "random_pet" "db_user" {
  separator = "_"
}

resource "random_password" "db_password" {
  length  = 50
  special = false
}

resource "aws_db_instance" "tracker" {
  allocated_storage               = 5
  auto_minor_version_upgrade      = true
  availability_zone               = data.aws_availability_zones.azs.names[0]
  backup_retention_period         = 1
  backup_window                   = "09:00-10:00"
  ca_cert_identifier              = "rds-ca-ecc384-g1"
  deletion_protection             = true
  copy_tags_to_snapshot           = true
  db_name                         = "tracker"
  db_subnet_group_name            = aws_db_subnet_group.private.name
  engine                          = "postgres"
  engine_version                  = "16.4"
  identifier                      = "tracker"
  instance_class                  = "db.t4g.micro"
  kms_key_id                      = aws_kms_key.tracker.arn
  maintenance_window              = "Mon:10:00-Mon:13:00"
  password                        = random_password.db_password.result
  username                        = random_pet.db_user.id
  multi_az                        = false
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.tracker.arn
  storage_encrypted               = true
  vpc_security_group_ids          = [aws_security_group.postgres_tracker.id]

  blue_green_update {
    enabled = true
  }
}

resource "aws_security_group" "postgres_tracker" {
  name        = "postgres-tracker"
  description = "Allow Tracker to talk to postgres"
  vpc_id      = data.aws_vpc.resolved.id
}

resource "aws_vpc_security_group_ingress_rule" "postgres_tracker" {
  security_group_id            = aws_security_group.postgres_tracker.id
  description                  = "Allow Tracker to talk to us"
  from_port                    = aws_db_instance.tracker.port
  to_port                      = aws_db_instance.tracker.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.tracker.id
}

resource "aws_db_subnet_group" "private" {
  name       = "private"
  subnet_ids = data.aws_subnets.private.ids
}
