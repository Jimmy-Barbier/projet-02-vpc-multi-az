# Security Group ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "Security Group pour l ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS depuis Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg-alb"
    Environment = var.env
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# Security Group EC2
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-sg-ec2"
  description = "Security Group pour les instances EC2 Flask"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Trafic Flask depuis ALB uniquement"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg-ec2"
    Environment = var.env
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# Security Group RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-sg-rds"
  description = "Security Group pour RDS MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL depuis EC2 uniquement"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg-rds"
    Environment = var.env
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}