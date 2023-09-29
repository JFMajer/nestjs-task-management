provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}
data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  # define which logs to enable
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # define retention in days for CloudWatch Logs
  cloudwatch_log_group_retention_in_days = 3

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.jump_host.arn
      username = "jump_host"
      groups   = ["system:masters"]
    }
  ]


  eks_managed_node_groups = {
    default_node_group = {
      create_launch_template = false
      launch_template_name   = ""
      name                   = "node-group-AL2"
      name                   = "node-group-1"
      capacity_type          = "SPOT"
      instance_types         = ["t3.medium", "t3.large"]

      ami_id                     = data.aws_ami.eks_default.image_id
      enable_bootstrap_user_data = true
      bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"

      pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      EOT

      post_bootstrap_user_data = <<-EOT
      echo "you are free little kubelet!"
      EOT

      min_size     = 1
      max_size     = 3
      desired_size = 2

      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]

      tags = {
        "nodegroup-role"      = "worker"
        "instance-life-cycle" = "Ec2Spot"
        "Name"                = "node-group-1"
      }
    }

  }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name             = "vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

}

resource "aws_security_group_rule" "jumphost-to-eks-controlplane" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.jump_host_sg.id
}

resource "helm_release" "ebs_csi_driver" {
  name       = "ebs-csi-driver"
  repository = "https://charts.deliveryhero.io/"
  chart      = "aws-ebs-csi-driver"
}

resource "kubernetes_namespace" "loki" {
  metadata {
    name = "loki"
  }
}

resource "helm_release" "loki" {
  name = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart = "loki-stack"
  namespace = kubernetes_namespace.loki.metadata[0].name

  set {
    name = "promtail.enabled"
    value = "true"
  }

  set {
    name = "grafana.enabled"
    value = "true"
  }
}
module "eks-load-balancer-controller" {
  source  = "lablabs/eks-load-balancer-controller/aws"
  version = "1.2.0"
  
  cluster_name = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.oidc_provider_arn
  cluster_oidc_issuer_client_id = module.eks.oidc_provider_arn
}