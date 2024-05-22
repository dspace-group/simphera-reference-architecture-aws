## v0.2.0
- RDS DB subnet group is now using VPC private subnets, instead of
separate, private DB subnets. Please check MIGRATION.md document
on procedure how to migrate existing deployments.
- added option to use preconfigured VPC and subnets, in case of 
customers who want to manage network infrastructure themselves.
You need to set ID of preconfigured VPC: if proper tagging is used on
subnets, subnet IDs will be filtered out from given VPC ID. If no proper 
tagging is used on subnets, you need to supply IDs of preconfigured subnets. 
If no VPC ID is given, VPC will be created instead (default behaviour).

## v0.1.0
Initial release of reference architecture
