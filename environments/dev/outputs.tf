output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.compute.bastion_public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = module.compute.bastion_instance_id
}

output "alb_sg_id" {
  description = "Security group ID for ALB"
  value       = module.security.alb_sg_id
}

output "bastion_sg_id" {
  description = "Security group ID for bastion"
  value       = module.security.bastion_sg_id
}

output "database_sg_id" {
  description = "Security group ID for database"
  value       = module.security.database_sg_id
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.endpoint
}

output "webserver_sg_id" {
  description = "Security group ID for web servers"
  value       = module.security.webserver_sg_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}
