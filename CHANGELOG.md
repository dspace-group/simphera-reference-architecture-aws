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
private DB subnets. Please check MIGRATION.md document on procedure how to
migrate existing deployments.

## v0.1.0

Initial release of reference architecture
