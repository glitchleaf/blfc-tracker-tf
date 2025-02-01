resource "random_pet" "db_user" {
  separator = "_"
}

resource "random_password" "db_password" {
  length  = 50
  special = false
}

resource "aws_db_instance" "tracker" {
  # checkov:skip=CKV2_AWS_30:Might be nice for debuggingg but kind of a hassle
  # checkov:skip=CKV_AWS_118:Useful for debugging but its spendy
  # checkov:skip=CKV_AWS_129:ditto
  # checkov:skip=CKV_AWS_157:no one is paying us to run this shit lol, I ain't going that hard with it
  # checkov:skip=CKV_AWS_161:not worth figuring out how to add IAM auth to Tracker
  #ts:skip=AC_AWS_0057
  #ts:skip=AC_AWS_0053
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
