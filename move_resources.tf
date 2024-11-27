moved {
  from = module.eks.module.aws_eks.aws_eks_cluster.this[0]
  to   = module.eks.aws_eks_cluster.eks
}
moved {
  from = module.eks.module.aws_eks.aws_iam_role.this[0]
  to   = module.eks.aws_iam_role.cluster_role
}

moved {
  from = module.eks.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
  to   = module.eks.aws_iam_role_policy_attachment.cluster_role["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}
moved {
  from = module.eks.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]
  to   = module.eks.aws_iam_role_policy_attachment.cluster_role["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]
}
moved {
  from = module.eks.module.kms[0].aws_kms_key.this
  to   = module.eks.aws_kms_key.cluster
}
moved {
  from = module.eks.module.kms[0].aws_kms_alias.this
  to   = module.eks.aws_kms_alias.cluster
}

moved {
  from = module.eks.kubernetes_config_map.aws_auth[0]
  to   = module.eks.kubernetes_config_map.aws_auth
}

moved {
  from = module.eks.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0]
  to   = module.eks.aws_iam_openid_connect_provider.oidc_provider
}

moved {
  from = module.eks.module.aws_eks.aws_security_group.cluster[0]
  to   = module.eks.aws_security_group.cluster
}

moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_443"]
  to   = module.eks.aws_security_group_rule.cluster["egress_nodes_443"]
}

moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_kubelet"]
  to   = module.eks.aws_security_group_rule.cluster["egress_nodes_kubelet"]
}

moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_443"]
  to   = module.eks.aws_security_group_rule.cluster["ingress_nodes_443"]
}

moved {
  from = module.eks.module.aws_eks.aws_security_group.node[0]
  to   = module.eks.aws_security_group.node
}

moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["egress_cluster_443"]
  to   = module.eks.aws_security_group_rule.node["egress_cluster_443"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["egress_https"]
  to   = module.eks.aws_security_group_rule.node["egress_https"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["egress_ntp_tcp"]
  to   = module.eks.aws_security_group_rule.node["egress_ntp_tcp"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["egress_ntp_udp"]
  to   = module.eks.aws_security_group_rule.node["egress_ntp_udp"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_tcp"]
  to   = module.eks.aws_security_group_rule.node["egress_self_coredns_tcp"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_udp"]
  to   = module.eks.aws_security_group_rule.node["egress_self_coredns_udp"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["ingress_cluster_443"]
  to   = module.eks.aws_security_group_rule.node["ingress_cluster_443"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["ingress_cluster_kubelet"]
  to   = module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]
  to   = module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]
}
moved {
  from = module.eks.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_udp"]
  to   = module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]
}
moved {
  from = module.eks.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["created"]
  to   = module.eks.aws_ec2_tag.cluster_primary_security_group["created"]
}

moved {
  from = module.eks.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["created_by"]
  to   = module.eks.aws_ec2_tag.cluster_primary_security_group["created_by"]
}
