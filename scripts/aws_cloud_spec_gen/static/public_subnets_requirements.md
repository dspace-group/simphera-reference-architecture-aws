
| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR blocks | Network size, ie number of available IPs per public subnet | 10.1.12.0/22 <br /> 10.1.16.0/22 <br /> 10.1.20.0/22 | yes |
| Tags | Metadata for organizing your AWS resources | "kubernetes.io/cluster/\<cluster name>" = "shared" <br /> "kubernetes.io/role/elb" = "1" <br /> "purpose" = "public" | yes |
| Network Access Lists | Allows or denies specific inbound or outbound traffic at the subnet level | Allow all inbound/outbound | yes |