
| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR block | Network size ie. number of available IPs in VPC | 10.1.0.0/18 | yes |
| Availability zones | How many AZs to spread VPC across | 3 (at least 2 for high availability) | yes |
| Private subnets | How many private subnets to create | 3 (at least 2 for high availability; one per each AZ) | yes |
| Public subnets | How many public subnets to create | 3 (at least 2 for high availability; one per each AZ) | yes |
| NAT gateway | Enable/disable NAT in VPC | enable | yes |
| Single NAT gateway | Controls how many NAT gateways/Elastic IPs to provision | enable | no |
| Internet gateway | Enable/disable IGW in VPC | enable | yes |
| DNS hostnames | Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses. | enable | yes |