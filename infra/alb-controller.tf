module "eks-load-balancer-controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"

  enabled = true

  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_id

  depends_on = [module.eks]
}

# resource "aws_iam_policy" "alb_controller_policy" {
#     name        = "alb-controller-policy"
#     description = "Policy for ALB Controller"
#     policy      = file("iam_policy.json")
# }