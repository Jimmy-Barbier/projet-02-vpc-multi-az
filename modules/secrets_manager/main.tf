resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-db-credentials-${var.env}"
  description             = "Credentials RDS MySQL pour ${var.project_name}"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.project_name}-db-credentials"
    Environment = var.env
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    dbname   = var.db_name
  })
}