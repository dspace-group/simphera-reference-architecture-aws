output "nodegroup_id" {
  value = aws_eks_node_group.managed_ng.id
}

output "nodegroup_role_id" {
  value = aws_iam_role.managed_ng.id
}
