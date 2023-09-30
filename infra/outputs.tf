output "rds_dns_name" {
  description = "The DNS name of the RDS instance, with port"
  value       = module.rds.db_instance_endpoint
}

output "instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}