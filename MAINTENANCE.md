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
