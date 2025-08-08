module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = "1.29"
  subnet_ids         = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id

  enable_irsa = true
  endpoint_public_access = true
  endpoint_public_access_cidrs = ["189.62.44.167/32"]
  
  access_entries = {
    myuser = {
      principal_arn = "arn:aws:iam::${local.account_id}:user/cloud_user"

      policy_associations = {
        view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      disk_size      = 30
      ami_type       = "AL2_x86_64"

    }
  }
}
