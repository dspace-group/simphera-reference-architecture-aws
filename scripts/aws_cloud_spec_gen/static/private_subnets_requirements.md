
| Requirement | Description |  Default value | Mandatory? |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR blocks | Network size, ie number of available IPs per private subnet | 10.1.0.0/22 <br /> 10.1.4.0/22 <br /> 10.1.8.0/22 | yes |
| Tags | Metadata for organizing your AWS resources | "kubernetes.io/cluster/\<cluster name>" = "shared" <br /> "kubernetes.io/role/elb" = "1" <br /> "purpose" = "private" | yes |
| Network Access Lists | Allows or denies specific inbound or outbound traffic at the subnet level | Allow all inbound/outbound | yes |