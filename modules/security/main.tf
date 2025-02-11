# Security Groups with minimal required access
resource "aws_security_group" "bastion" {
  name_prefix = "${local.name_prefix}bastion-"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}bastion-sg"
  })
}

resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}alb-"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}alb-sg"
  })
}

resource "aws_security_group" "webserver" {
  name_prefix = "${local.name_prefix}web-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}web-sg"
  })
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${local.name_prefix}db-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from web servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}db-sg"
  })
}

# SSM Parameter Access
resource "aws_iam_policy" "ssm_access" {
  name        = "${local.name_prefix}ssm-access"
  description = "Allow access to SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ssm:GetParameter*"]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_prefix}/*"
        ]
      }
    ]
  })
}

# KMS for SSM encryption
resource "aws_kms_key" "ssm" {
  description             = "${local.name_prefix}ssm-encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_kms_alias" "ssm" {
  name          = "alias/${local.name_prefix}ssm-key"
  target_key_id = aws_kms_key.ssm.key_id
}

# Generate RSA key
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "bastion" {
  key_name   = "${local.name_prefix}bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
  tags       = local.tags
}

# Store private key in SSM Parameter Store
resource "aws_ssm_parameter" "bastion_private_key" {
  name        = "${local.ssm_prefix}/bastion/ssh_private_key"
  description = "Private key for bastion host SSH access"
  type        = "SecureString"
  value       = tls_private_key.bastion.private_key_pem
  key_id      = aws_kms_key.ssm.key_id
  tags        = local.tags
}
