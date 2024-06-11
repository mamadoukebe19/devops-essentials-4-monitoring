# ------------------
# AWS EKS Resources.
# ------------------

# Description: EKS cluster used to host
# Terraform registry: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.15.3
# AWS documentation: https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.0"

  cluster_name                   = "lcf-eks-monitoring"
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true
  openid_connect_audiences       = ["sts.amazonaws.com"]
  enable_irsa                    = true

  # EKS Managed Node Group configuration.
  eks_managed_node_groups = {
    eks-node = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      labels = {
        "eks.lcf.io/managed-by" = "eks"
      }
    }
  }

  # Clustrer add-ons configuration.
  cluster_addons = {
    coredns = {
      addon_version = "v1.11.1-eksbuild.4"
    }
    kube-proxy = {
      addon_version = "v1.29.0-eksbuild.1"
    }
    vpc-cni = {
      addon_version = "v1.16.0-eksbuild.1"
    }
  }

  # Networking configuration.
  vpc_id     = "vpc-0fbe950501d1f5133"
  subnet_ids = ["subnet-0ea9578f3d7825a27", "subnet-0a444b818bc4afc82"]


  # Additional security group rules for cluster security group ingress.
  cluster_security_group_additional_rules = {
    ingress = {
      description                   = "To internal cluster API on port 443"
      type                          = "ingress"
      from_port                     = 443
      to_port                       = 443
      protocol                      = "tcp"
      cidr_blocks                   = ["10.0.0.0/8"]
      source_cluster_security_group = true
    }
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Ssh ports"
      protocol                   = "tcp"
      from_port                  = 22
      to_port                    = 22
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

}
