output "rds_dns_name" {
  description = "The DNS name of the RDS instance, with port"
  value       = module.rds.db_instance_endpoint
}

output "instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "eks_oidc_issuer_url" {
  description = "The OIDC Issuer URL of the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_oidc_issuer_arn" {
  description = "The OIDC Issuer ARN of the EKS cluster"
  value       = module.eks.oidc_provider_arn
}

output "eks_cluster_id" {
  description = "The EKS cluster ID"
  value       = module.eks.cluster_id
}

output "identity-oidc-issuer" {
  value = module.eks.oidc_provider
}

output "cluster_primary_sg_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_sg_id" {
  value = module.eks.cluster_security_group_id
}