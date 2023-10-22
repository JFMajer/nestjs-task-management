################################################################################
# EKS Cluster
################################################################################

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
    # ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.jump_host.arn
      username = "jump_host"
      groups   = ["system:masters"]
    },
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    }
  ]

  eks_managed_node_groups = {
    default_node_group = {
      create_launch_template = false
      launch_template_name   = ""
      name                   = "node-group-1"
      capacity_type          = "SPOT"
      instance_types         = ["c7i.xlarge"]

      ami_id = data.aws_ami.eks_default.image_id

      pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      EOT

      post_bootstrap_user_data = <<-EOT
      echo "you are free little kubelet!"
      EOT

      min_size     = 2
      max_size     = 3
      desired_size = 2

      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-role"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      ]
      labels = {
        role = "worker"
      }
    }

  }
}

resource "aws_ec2_tag" "cluster_sg_additional_tag" {
  resource_id = module.eks.cluster_primary_security_group_id
  key         = "karpenter.sh/discovery"
  value       = module.eks.cluster_name
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

# resource "helm_release" "ebs_csi_driver" {
#   name       = "ebs-csi-driver"
#   repository = "https://charts.deliveryhero.io/"
#   chart      = "aws-ebs-csi-driver"
# }

resource "helm_release" "task-management" {
  name  = "task-management"
  chart = "../${path.module}/helm/task-management-0.0.2.tgz"

  set {
    name  = "database.host"
    value = split(":", module.rds.db_instance_endpoint)[0]
  }

  set {
    name  = "database.password"
    value = var.db_password
  }
}