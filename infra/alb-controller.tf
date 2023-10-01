resource "aws_iam_policy" "alb_controller_policy" {
  name        = "alb-controller-policy"
  description = "Policy for ALB Controller"
  policy      = file("iam_policy.json")
}

resource "aws_iam_policy_document" "load-balancer-role-trust-policy" {
    statement {
        effect = "Allow"
        actions = [
            "ats:AssumeRoleWithWebIdentity"
        ]
        principals {
            type        = "Federated"
            identifiers = [module.eks.oidc_provider_arn]
        }
        condition {
            test = "StringEquals"
            variable = "oidc.eks.eu-north-1.amazonaws.com/id/${module.eks.identity[0].oidc[0].issuer}:aud"
            values = [
                "sts.amazonaws.com"
            ]
        }
        condition {
            test = "StringEquals"
            variable = "oidc.eks.eu-north-1.amazonaws.com/id/${module.eks.identity[0].oidc[0].issuer}:sub"
            values = [
                "system:serviceaccount:kube-system:aws-load-balancer-controller"
            ]
        }
    }
} 

resource "iaws_iam_role" "load-balancer-role" {
    name = "aws-load-balancer-controller"
    assume_role_policy = aws_iam_policy_document.load-balancer-role-trust-policy.json
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy_attachment" {
  role       = aws_iam_role.load-balancer-role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.load-balancer-role.arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
  }
}


