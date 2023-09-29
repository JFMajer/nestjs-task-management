output "rds_dns_name" {
  description = "The DNS name of the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  description = "The ARN of the RDS secret"
  value       = module.rds.db_secret_arn
}