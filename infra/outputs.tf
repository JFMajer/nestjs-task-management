output "rds_dns_name" {
  description = "The DNS name of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "rds_secret_arn" {
  description = "The ARN of the RDS secret in Secrets Manager"
  value       = aws_db_instance.this.associated_secret[0].arn
}