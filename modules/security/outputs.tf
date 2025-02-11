output "bastion_sg_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}

output "alb_sg_id" {
  description = "ID of the application load balancer security group"
  value       = aws_security_group.alb.id
}

output "webserver_sg_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.webserver.id
}

output "database_sg_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "bastion_key_name" {
  description = "Name of the bastion host key pair"
  value       = aws_key_pair.bastion.key_name
}
