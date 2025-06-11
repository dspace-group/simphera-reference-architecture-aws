## v0.6.0

- Added option to use SPOT instances for execution nodes.
- Implement optional creation of IVS buckets

## v0.5.0

- Implemented deployment of an OpenSearch Domain for usage in IVS
- Update default version for helm chart of `ingress-nginx` to `4.12.1` (controller version `1.12.1`)
- Increase required terraform version to 1.9.0
- Added optional creation of Windows based node group `winexecnode`
- Added IVS related ingress rules to license server

## v0.4.0

- Implemented initial support for IVS.
- replaced terraform-aws-eks-blueprints for the `eks` module with custom implementation of module `modules/eks`

## v0.3.0

- replaced terraform-aws-eks-blueprint addon ingress-nginx with module `modules/k8s_eks_addons/ingress-nginx.tf`
- replaced terraform-aws-eks-blueprint addon cluster-autoscaler with module `modules/k8s_eks_addons/cluster-autoscaler.tf`
- replaced terraform-aws-eks-blueprint addon coredns with module `modules/k8s_eks_addons/coredns.tf`
- replaced terraform-aws-eks-blueprint addon efs csi driver with module `modules/k8s_eks_addons/efs-csi.tf`
- replaced terraform-aws-eks-blueprint addon kube_proxy with module `modules/k8s_eks_addons/kube-proxy.tf`
- replaced terraform-aws-eks-blueprint addon ebs-csi-driver with module `modules/k8s_eks_addons/ebs-csi.tf`
- replaced terraform-aws-eks-blueprint addon vpc-cni with module `modules/k8s_eks_addons/vpc-cni.tf`
- added addon aws-mountpoint-s3-csi-driver with module `modules/k8s_eks_addons/s3-csi.tf`
- replaced terraform-aws-eks-blueprint addon aws-load-balancer-controller with module `modules/k8s_eks_addons/aws-load-balancer-controller.tf`

## v0.2.0

- added option to use preconfigured VPC and subnets, in case of customers who
want to manage network infrastructure themselves. You need to set ID of
preconfigured VPC: if proper tagging is used on subnets, subnet IDs will be
filtered out from given VPC ID. If no proper tagging is used on subnets, you
need to supply IDs of preconfigured subnets. If no VPC ID is given, VPC and
subnets will be created instead (default behaviour).
- There is now a separate security group for the license server
- CodeMeter runtime is now automatically installed and license server is
configured as network server
- Disk size is now modifiable for not only RDS but all EKS nodes.
- Instance type list is now fixed with the selected instance types that are
compatible with k8s and workload (e.g. cpu type, cpu and memory requests;
16 Cores, 64 GiB). The list is ordered in such a way, so that the most cost
efficient EC2 instance type is selected first.
- RDS DB subnet group is now using VPC private subnets, instead of separate,
private DB subnets. Please check MAINTENANCE.md document on procedure how to
migrate existing deployments.
- Enabled usage of pull through cache in ECR

## v0.1.0

Initial release of reference architecture
