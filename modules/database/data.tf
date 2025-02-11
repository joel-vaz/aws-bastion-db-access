# Fetch secret parameters
data "aws_ssm_parameter" "db_password" {
  name            = "${var.ssm_parameter_prefix}/${var.environment}/database/password"
  with_decryption = true
}

# Fetch regular parameters
data "aws_ssm_parameter" "db_username" {
  name = "${var.ssm_parameter_prefix}/${var.environment}/database/username"
}
