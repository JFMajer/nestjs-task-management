output "rds_dns_name" {
  description = "The DNS name of the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  description = "The ARN of the RDS secret in Secrets Manager"
  value       = module.rds.db_instance_master_user_secret_arn
}