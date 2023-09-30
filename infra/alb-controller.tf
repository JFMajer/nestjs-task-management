# module "eks-load-balancer-controller" {
#   source  = "lablabs/eks-load-balancer-controller/aws"
#   version = "1.2.0"

#   cluster_name                     = module.eks.cluster_name
#   cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
#   cluster_identity_oidc_issuer     = module.eks.oidc_provider_arn
# }
