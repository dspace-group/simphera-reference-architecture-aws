# Migrate AWS RDS databases to use different private subnets

This procedure explains how to migrate AWS RDS databases, deployed with reference architecture, from using separate, private DB subnets to (re-)using
private subnets already deployed with VPC. This only applies to already existing deployments, new deployments are not affected.
The change was introduced with v0.2.0 of SIMPHERA AWS reference architecture.

## Steps

1. Check your existing deployment and make sure everything works etc.
2. Delete "keycloak" and "simphera" databases, making sure that final snapshot is created. When deleting the databases via the AWS Management Console, the option to create a final snapshot is selected by default.
3. After DBs are deleted, update DB subnet group, remove DB specific subnets and add VPC private subnets
4. Restore DBs from snapshots taken, selecting same configuration options as original DBs (names, VPCs, security groups etc.)
5. Remove old DB subnet group from Terraform state, eg.: terraform state rm module.vpc.aws_db_subnet_group.database[0]
6. Import new DB subnet group into Terraform state, eg.: terraform import module.simphera_instance[\"production\"].aws_db_subnet_group.default <infrastructure name>-vpc
7. Re-run Terraform to refresh the state and apply any small configuration changes in-place, which were missed in previous steps - use "terraform apply" command
8. Check Simphera deployment and make sure all pods are running fine, endpoints are reachable etc.

# Rotating Credentials

Credentials can be manually rotated:
Open the secret in the Secrets Manager console and change the passwords manually.
Fill in the placeholders `<namespace>` and the `<path_to_kubeconfig>` and run the following command to remove SIMPHERA from your Kubernetes cluster:

```bash
helm delete simphera -n <namespace> --kubeconfig <path_to_kubeconfig>
```

Reinstall the SIMPHERA Quickstart Helmchart so that all Kubernetes pods and jobs will retrieve the new credentials.
Important: During credentials rotation, SIMPHERA will not be available for a short period.

# Updating CA certificate

## Updating by using AWS CLI

To use the AWS CLI to change the CA from rds-ca-2019 to rds-ca-rsa2048-g1 for a DB instancer, call the modify-db-instance command. Specify the DB instance identifier and the --ca-certificate-identifier option along with the AWS profile and its region.

```
aws rds modify-db-instance `
    --db-instance-identifier __db_instance__ `
    --ca-certificate-identifier rds-ca-rsa2048-g1 `
    --profile __profile_name__ `
    --region __region__
```

## Updating by applying maintenance

To update your CA certificate by applying maintenance:

1. Sign in to the AWS Management Console and open the Amazon RDS console.
2. In the navigation pane, choose Certificate update. The Databases requiring certificate update page appears.
3. Choose the DB instance that you want to update. You can schedule the certificate rotation for your next maintenance window by choosing Schedule. Apply the rotation immediately by choosing Apply now.
4. You are prompted to confirm the CA certificate rotation. Pick rds-ca-rsa2048-g1 and click Schedule/Confirm.

# Migrate ingress-nginx addon to the module

To migrate from terraform-aws-eks-blueprint addon ingress-nginx to custom module `modules/k8s_eks_addons/ingress-nginx.tf` follow steps:

1. Enable ingress-nginx in terraform.tfvars
2. create 'move.tf' in repository root
3. Add following code:

```
moved {
  from = module.eks-addons.module.ingress_nginx[0].module.helm_addon.helm_release.helm_addon[0]
  to   = module.k8s_eks_addons.helm_release.ingress_nginx[0]
}
moved {
  from = module.eks-addons.module.ingress_nginx[0].kubernetes_namespace_v1.this[0]
  to   = module.k8s_eks_addons.kubernetes_namespace_v1.ingress_nginx[0]
}
```

4. Run command:

```
terraform apply
```

5. Remove `move.tf` file

# Migrate cluster-autoscaler addon to the module

To migrate from terraform-aws-eks-blueprint addon cluster-autoscaler to custom module `modules/k8s_eks_addons/cluster-autoscaler.tf` follow steps:

1. create 'move.tf' in repository root
2. Add following code:

```
moved {
  from = module.eks-addons.module.cluster_autoscaler[0].data.aws_iam_policy_document.cluster_autoscaler
  to   = module.k8s_eks_addons.data.aws_iam_policy_document.cluster_autoscaler[0]
}
moved {
  from = module.eks-addons.module.cluster_autoscaler[0].aws_iam_policy.cluster_autoscaler
  to   = module.k8s_eks_addons.aws_iam_policy.cluster_autoscaler[0]
}
moved {
  from = module.eks-addons.module.cluster_autoscaler[0].module.helm_addon.helm_release.addon[0]
  to   = module.k8s_eks_addons.helm_release.cluster_autoscaler[0]
}
moved {
  from = module.eks-addons.module.cluster_autoscaler[0].module.helm_addon.module.irsa[0].aws_iam_role.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role.cluster_autoscaler[0]
}
moved {
  from = module.eks-addons.module.cluster_autoscaler[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role_policy_attachment.cluster_autoscaler[0]
}
moved {
  from = module.eks-addons.module.cluster_autoscaler[0].module.helm_addon.module.irsa[0].kubernetes_service_account_v1.irsa[0]
  to   = module.k8s_eks_addons.kubernetes_service_account_v1.cluster_autoscaler[0]
}
```

3. Run command:

```
terraform apply
```

4. Remove `move.tf` file

# Migrate coredns addon to the module

To migrate from terraform-aws-eks-blueprint addon coredns to custom module `modules/k8s_eks_addons/coredns.tf` follow steps:

1. create 'move.tf' in repository root
2. Add following code:

```
moved {
  from = module.eks-addons.module.aws_coredns[0].data.aws_eks_addon_version.this
  to   = module.k8s_eks_addons.data.aws_eks_addon_version.coredns[0]
}
moved {
  from = module.eks-addons.module.aws_coredns[0].aws_eks_addon.coredns[0]
  to   = module.k8s_eks_addons.aws_eks_addon.coredns[0]
}
```

3. Run command:

```
terraform apply
```

4. Remove `move.tf` file

# Migrate efs csi driver addon to the module

To migrate from terraform-aws-eks-blueprint addon efs csi driver to custom module `modules/k8s_eks_addons/efs-csi.tf` follow steps:

1. create 'move.tf' in repository root
2. Add following code:

```
moved {
  from = module.eks-addons.module.aws_efs_csi_driver[0].data.aws_eks_addon_version.this
  to   = module.k8s_eks_addons.data.aws_eks_addon_version.aws_efs_csi_driver[0]
}
moved {
  from = module.eks-addons.module.aws_efs_csi_driver[0].aws_eks_addon.aws_efs_csi_driver[0]
  to   = module.k8s_eks_addons.aws_eks_addon.aws_efs_csi_driver[0]
}
moved {
  from = module.eks-addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role.efs_csi_driver_role
}
moved {
  from = module.eks-addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role_policy_attachment.efs_csi_driver_policy_attachment[0]
}
```

3. Run command:

```
terraform apply
```

4. Remove `move.tf` file

# Migrate kube_proxy addon to the module
To migrate from terraform-aws-eks-blueprint addon kube_proxy to custom module `modules/k8s_eks_addons/kube-proxy.tf` follow steps:

1. create 'move.tf' in repository root
2. Add following code:
```
moved {
  from = module.eks-addons.module.aws_kube_proxy[0].data.aws_eks_addon_version.this
  to   = module.k8s_eks_addons.data.aws_eks_addon_version.kube_proxy
}
moved {
  from = module.eks-addons.module.aws_kube_proxy[0].aws_eks_addon.kube_proxy
  to   = module.k8s_eks_addons.aws_eks_addon.kube_proxy
}
```
3. Run command:
```
terraform apply
```
4. Remove `move.tf` file

# Migrate ebs_csi addon to the module
To migrate from terraform-aws-eks-blueprint addon ebs_csi to custom module `modules/k8s_eks_addons/ebs-csi.tf` follow steps:

1. create 'move.tf' in repository root
2. Add following code:
```
moved {
  from =  module.eks-addons.module.aws_ebs_csi_driver[0].data.aws_eks_addon_version.this
  to   = module.k8s_eks_addons.data.aws_eks_addon_version.aws_ebs_csi_driver
}
moved {
  from = module.eks-addons.module.aws_ebs_csi_driver[0].aws_eks_addon.aws_ebs_csi_driver[0]
  to   = module.k8s_eks_addons.aws_eks_addon.aws_ebs_csi_driver
}
moved {
  from = module.eks-addons.module.aws_ebs_csi_driver[0].module.irsa_addon[0].aws_iam_role.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role.ebs_csi_driver_role
}
moved {
  from = module.eks-addons.module.aws_ebs_csi_driver[0].module.irsa_addon[0].aws_iam_role_policy_attachment.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role_policy_attachment.ebs_csi_driver_policy_attachment
}

```
3. Run command:
```
terraform apply
```
4. Remove `move.tf` file

# Migrate vpc_cni addon to the module
To migrate from terraform-aws-eks-blueprint addon vpc_cni to custom module `modules/k8s_eks_addons/vpc-cni.tf` follow steps:

1. create 'move.tf' in repository root
2. Add following code:
```
moved {
  from = module.eks-addons.module.aws_vpc_cni[0].data.aws_eks_addon_version.this
  to   = module.k8s_eks_addons.data.aws_eks_addon_version.aws_vpc_cni
}
moved {
  from = module.eks-addons.module.aws_vpc_cni[0].aws_eks_addon.vpc_cni
  to   = module.k8s_eks_addons.aws_eks_addon.aws_vpc_cni
}
moved {
  from = module.eks-addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role.aws_vpc_cni_role
}
moved {
  from = module.eks-addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role_policy_attachment.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role_policy_attachment.aws_vpc_cni_policy_attachment
}

```
3. Run command:
```
terraform apply
```
4. Remove `move.tf` file


# Migrate aws_load_balancer_controller addon to the module
To migrate from terraform-aws-eks-blueprint addon aws_load_balancer_controller to custom module `modules/k8s_eks_addons/aws-load-balancer-controller.tf` follow steps:

1. create 'move.tf' in repository root
2. Add following code:
```
moved {
  from = module.eks-addons.module.aws_load_balancer_controller[0].data.aws_iam_policy_document.aws_load_balancer_controller
  to   = module.k8s_eks_addons.data.aws_iam_policy_document.aws_load_balancer_controller[0]
}
moved {
  from = module.eks-addons.module.aws_load_balancer_controller[0].aws_iam_policy.aws_load_balancer_controller
  to   = module.k8s_eks_addons.aws_iam_policy.aws_load_balancer_controller[0]
}
moved {
  from = module.eks-addons.module.aws_load_balancer_controller[0].module.helm_addon.helm_release.addon[0]
  to   = module.k8s_eks_addons.helm_release.aws_load_balancer_controller[0]
}
moved {
  from = module.eks-addons.module.aws_load_balancer_controller[0].module.helm_addon.module.irsa[0].aws_iam_role.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role.aws_load_balancer_controller[0]
}
moved {
  from = module.eks-addons.module.aws_load_balancer_controller[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[0]
  to   = module.k8s_eks_addons.aws_iam_role_policy_attachment.aws_load_balancer_controller[0]
}
moved {
  from = module.eks-addons.module.aws_load_balancer_controller[0].module.helm_addon.module.irsa[0].kubernetes_service_account_v1.irsa[0]
  to   = module.k8s_eks_addons.kubernetes_service_account_v1.aws_load_balancer_controller[0]
}

```
3. Run command:
```
terraform apply
```
4. Remove `move.tf` file

# Migrate from v0.3.0 to v0.4.0
By removing terraform blueprints for the deployment of EKS, terraform state has been changed significantly. Some resources are no longer necessary, some new are introduced, and some of them are changed, but most of the resources are moved.
For successful migration to the new release you should use "moved" block to minimize recreation of the resources.
For quicker migration, it is suggested to scale down all of the node groups in AWS portal to 0 (minimum and desired node count).

1. In your `providers.tf`, for data block `aws_eks_cluster` and `aws_eks_cluster_auth` change value of argument `name` with hardcoded name of your EKS. This change can be reverted uppon successfull migration.

2. Create `move.tf` file, and according to the flags you have (`variables.tf`), add following moved blocks (flags mostly affect node groups and their related resources):
```terraform
moved {
  from = module.eks.module.kms[0].aws_kms_alias.this
  to   = module.eks.aws_kms_alias.cluster
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
  from = module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  to   = module.eks.module.node_group["default"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
  to   = module.eks.module.node_group["default"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  to   = module.eks.module.node_group["default"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  to   = module.eks.module.node_group["default"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  to   = module.eks.module.node_group["execnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
  to   = module.eks.module.node_group["execnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  to   = module.eks.module.node_group["execnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  to   = module.eks.module.node_group["execnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuivsnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  to   = module.eks.module.node_group["gpuivsnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuivsnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
  to   = module.eks.module.node_group["gpuivsnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuivsnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  to   = module.eks.module.node_group["gpuivsnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuivsnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  to   = module.eks.module.node_group["gpuivsnodes"].aws_iam_role_policy_attachment.node_group["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

moved {
  from = module.eks.module.aws_eks.aws_eks_cluster.this[0]
  to   = module.eks.aws_eks_cluster.eks
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_instance_profile.managed_ng[0]
  to   = module.eks.module.node_group["default"].aws_iam_instance_profile.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_instance_profile.managed_ng[0]
  to   = module.eks.module.node_group["execnodes"].aws_iam_instance_profile.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_instance_profile.managed_ng[0]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_iam_instance_profile.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuivsnodes"].aws_iam_instance_profile.managed_ng[0]
  to   = module.eks.module.node_group["gpuivsnodes"].aws_iam_instance_profile.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_launch_template.managed_node_groups[0]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_launch_template.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuivsnodes"].aws_launch_template.managed_node_groups[0]
  to   = module.eks.module.node_group["gpuivsnodes"].aws_launch_template.node_group
}

moved {
  from = module.eks.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0]
  to   = module.eks.aws_iam_openid_connect_provider.oidc_provider
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["default"].aws_eks_node_group.managed_ng
  to   = module.eks.module.node_group["default"].aws_eks_node_group.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_eks_node_group.managed_ng
  to   = module.eks.module.node_group["execnodes"].aws_eks_node_group.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_eks_node_group.managed_ng
  to   = module.eks.module.node_group["gpuexecnodes"].aws_eks_node_group.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuivsnodes"].aws_eks_node_group.managed_ng
  to   = module.eks.module.node_group["gpuivsnodes"].aws_eks_node_group.node_group
}

moved {
  from = module.eks.module.kms[0].aws_kms_key.this
  to   = module.eks.aws_kms_key.cluster
}

moved {
  from = module.eks.kubernetes_config_map.aws_auth[0]
  to   = module.eks.kubernetes_config_map.aws_auth
}

moved {
  from = module.eks.module.aws_eks.aws_iam_role.this[0]
  to   = module.eks.aws_iam_role.cluster_role
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role.managed_ng[0]
  to   = module.eks.module.node_group["default"].aws_iam_role.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role.managed_ng[0]
  to   = module.eks.module.node_group["execnodes"].aws_iam_role.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role.managed_ng[0]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_iam_role.node_group
}

moved {
  from = module.eks.module.aws_eks_managed_node_groups["gpuivsnodes"].aws_iam_role.managed_ng[0]
  to   = module.eks.module.node_group["gpuivsnodes"].aws_iam_role.node_group
}

moved {
  from = module.eks.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["created"]
  to   = module.eks.aws_ec2_tag.cluster_primary_security_group["created"]
}

moved {
  from = module.eks.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["created_by"]
  to   = module.eks.aws_ec2_tag.cluster_primary_security_group["created_by"]
}

moved {
  from = aws_autoscaling_group_tag.default_node-template_resources_ephemeral-storage
  to   = module.eks.module.node_group["default"].aws_autoscaling_group_tag.ephemeral_storage
}

moved {
  from = aws_autoscaling_group_tag.execnodes
  to   = module.eks.module.node_group["execnodes"].aws_autoscaling_group_tag.labels["purpose"]
}

moved {
  from = aws_autoscaling_group_tag.execnodes_node-template_resources_ephemeral-storage
  to   = module.eks.module.node_group["execnodes"].aws_autoscaling_group_tag.ephemeral_storage
}

moved {
  from = aws_autoscaling_group_tag.gpuexecnodes[0]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_autoscaling_group_tag.labels["purpose"]
}

moved {
  from = aws_autoscaling_group_tag.gpuexecnodes_node-template_resources_ephemeral-storage[0]
  to   = module.eks.module.node_group["gpuexecnodes"].aws_autoscaling_group_tag.ephemeral_storage
}

moved {
  from = aws_autoscaling_group_tag.gpuivsnodes[0]
  to   = module.eks.module.node_group["gpuivsnodes"].aws_autoscaling_group_tag.labels["purpose"]
}

moved {
  from = module.k8s_eks_addons.aws_eks_addon.aws_vpc_cni
  to   = module.eks.aws_eks_addon.aws_vpc_cni
}

moved {
  from = module.k8s_eks_addons.aws_iam_role.aws_vpc_cni_role
  to   = module.eks.aws_iam_role.aws_vpc_cni_role

}

moved {
  from = module.k8s_eks_addons.aws_iam_role_policy_attachment.aws_vpc_cni_policy_attachment
  to   = module.eks.aws_iam_role_policy_attachment.aws_vpc_cni_policy_attachment
}
```

3. Run init command:
```
terraform init
```

4. Remove state for data that has changed provider:
```
terraform state rm "module.eks.data.http.eks_cluster_readiness[0]"
```

5. Add cloudwatch log group to the state:
```
terraform import "module.eks.aws_cloudwatch_log_group.log_group[0]" "/aws/eks/YOUR_CLUSTER_NAME/cluster"
```

6. Run apply command:
```
terraform apply
```

7. Remove `move.tf` file.
