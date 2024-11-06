# Migrate AWS RDS databases to use different private subnets

This procedure explains how to migrate AWS RDS databases, deployed with reference architecture, from using separate, private DB subnets to (re-)using
private subnets already deployed with VPC. This only applies to already existing deployments, new deployments are not affected.
The change was introduced with v0.2.0 of SIMPHERA AWS reference architecture.

## Steps:
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
To migrate from terraform-aws-eks-blueprint addon cluster-autoscaler to custom module `modules/k8s_eks_addons/coredns.tf` follow steps:

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


