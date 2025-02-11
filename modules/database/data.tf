# Fetch secret parameters
data "aws_ssm_parameter" "db_password" {
  name            = "/${var.project_name}/${var.environment}/database/password"
  with_decryption = true
}

# Fetch regular parameters
data "aws_ssm_parameter" "db_username" {
  name = "/${var.project_name}/${var.environment}/database/username"
}
