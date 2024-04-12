#Migrate AWS RDS databases to use different private subnets

This procedure explains how to migrate AWS RDS databases, deployed with reference architecture, from using separate, private DB subnets to (re-)using 
private subnets already deployed with VPC. This only applies to already existing deployments, new deployments are not affected.
The change was introduced with v0.2.0 of reference architecture.

##Steps:
1. Check your existing deployment and make sure everything works etc. (no issues, pods not starting and so on)
2. Delete "keycloak" and "simphera" databases, making sure that final snapshot is created (it is automatically selected option when deleting DB)
3. After DBs are deleted, update DB subnet group, remove DB specific subnets and add VPC private subnets
4. Restore DBs from snapshots taken, selecting same configuration options as original DBs (names, VPCs, security groups etc.)
5. Remove old DB subnet group from Terraform state, eg.: terraform state rm module.vpc.aws_db_subnet_group.database[0]
6. Import new DB subnet group into Terraform state, eg.: terraform import module.simphera_instance[\"production\"].aws_db_subnet_group.default <infrastructure name>-vpc
7. Re-run Terraform to refresh the state and apply any small configuration changes in-place, which were missed in previous steps - use "terraform apply" command
8. Check Simphera deployment and make sure all pods are running fine, endpoints are reachable etc.

