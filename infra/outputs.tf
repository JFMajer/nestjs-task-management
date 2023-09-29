output "rds_dns_name" {
  description = "The DNS name of the RDS instance"
  value       = module.rds.db_instance_endpoint
}
