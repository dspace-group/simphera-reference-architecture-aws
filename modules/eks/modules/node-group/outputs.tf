output "nodegroup_id" {
  value = aws_eks_node_group.node_group.id
}

output "nodegroup_role_id" {
  value = aws_iam_role.node_group.id
}
