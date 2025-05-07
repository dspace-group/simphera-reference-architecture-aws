
| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| Routes | Minimum routes for network communication to work | 0.0.0.0/0 to \<NAT gateway> <br /> \<vpcCidrBlock> to local | yes |
| Subnet associations | Apply route table routes to a particular subnet | Explicit, all private subnets | yes |