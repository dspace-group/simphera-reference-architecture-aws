# <a name="Category_Compute"></a> ![Compute](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/Compute.png) Compute

## <a name="Service_Amazon Elastic Compute Cloud"></a> ![Amazon Elastic Compute Cloud](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2.png) Amazon Elastic Compute Cloud

### <a name="ResourceEC2Instance"></a>![EC2 Instance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2Instance.png) EC2 Instance
| AMI Name | Platform | Description | Mandatory |
| -------- | -------- | ----------- | --------- |
| amazon-eks-node | Linux/UNIX | Default node pool instances (auto-scaled) | Yes |
| amazon-eks-node | Linux/UNIX | Execution node pool instances (auto-scaled) | No |
| Windows_Server-2022-English-Core-EKS_Optimized | Windows | Windows Execution node pool instances (auto-scaled) | No |
| ubuntu-eks/k8s_<k8s version>/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server | Linux/UNIX | GPU Execution node pool instances (auto-scaled) | No |
| amzn2-ami-hvm-2.0.20210813.1-x86_64-gp2 | Amazon Linux  | dSPACE license server  | No |

### <a name="Resource_Elastic IP address"></a>![Elastic IP address](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2ElasticIPAddress.png) Elastic IP address
| Description |
| ----------- |
| Elastic IP Address for NAT Gateway |

### <a name="Resource_Launch template"></a>Launch template
| Name | Mandatory |
| ---- | ---------- |
| Launch template for default node pool. | Yes |
| Launch template for execution node pool. | No |
| Launch template for GPU execution node pool. | No |
| Launch template for IVS GPU execution node pool. | No |
| Launch template for IVS WIndows execution node pool. | No |

# <a name="Category_Containers"></a> ![Containers](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/Containers.png) Containers

## <a name="Service_Amazon Elastic Kubernetes Service"></a> ![Amazon Elastic Kubernetes Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/ElasticKubernetesService.png) Amazon Elastic Kubernetes Service

### <a name="Resource_Cluster"></a>Cluster
| Name | Description |
| ---- | ----------- |
| <cluster name> | EKS Kubernetes cluster |

### <a name="Resource_Add-on"></a>Add-on
| Name | Mandatory |
| ---- | ---------- |
| vpc-cni | Yes |
| kube-proxy | Yes |
| coredns | No |
| aws-ebs-csi-driver | No |
| aws-efs-csi-driver | No |
| aws-mountpoint-s3-csi-driver | No |

### <a name="Resource_Node group"></a>Node group
| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <cluster name>-default | Node group for default node pool. | Yes |
| <cluster name>-execnodes | Node group for execution node pool. | No |
| <cluster name>-gpuexecnodes-<driver version> | Node group for GPU execution node pool. | No |
| <cluster name>-gpuivsnodes | Node group for IVS GPU execution node pool. | No |
| <cluster name>-winexecnodes | Node group for IVS WIndows execution node pool. | No |

# <a name="Category_Database"></a> ![Database](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/Database.png) Database

## <a name="Service_Amazon Relational Database"></a> ![Amazon Relational Database](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/RDS.png) Amazon Relational Database

### <a name="Resource_PostgreSQL instance"></a>![PostgreSQL instance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/AuroraPostgreSQLInstance.png) PostgreSQL instance
| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <cluster name>-<environment>-simphera | Store data records of items like projects, test suites, etc. | Yes |
| <cluster name>-<environment>-keycloak | Keycloak stores SIMPHERA users in a separate Amazon RDS PostgreSQL instance. | Yes |

### <a name="Resource_Subnet group"></a>Subnet group
| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <cluster name>-<environment>-vpc | Amazon Relational Database subnet group used for simphera and keycloak database instances | Yes |

# <a name="Category_Management & Governance"></a> ![Management & Governance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/ManagementGovernance.png) Management & Governance

## <a name="Service_Amazon CloudWatch"></a> ![Amazon CloudWatch](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatch.png) Amazon CloudWatch

### <a name="Resource_Log groups"></a>![Log groups](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatchLogs.png) Log groups
| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| /aws/eks/<cluster name>/cluster | Node metrics and Kubernetes system logs. | No |
| /aws/rds/instance/<cluster name>-<environment>-keycloak/postgresql | Keycloak database logs. | No |
| /aws/rds/instance/<cluster name>-<environment>-simphera/postgresql | Simphera database logs | No |
| /aws/vpc/<cluster name> | VPC logs | No |
| /aws/ssm/<cluster name>/scan | EC2 scan maintenance logs | No |
| /aws/ssm/<cluster name>/install | EC2 maintenance installation logs | No |

# <a name="Category_Networking & Content Delivery"></a> ![Networking & Content Delivery](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/NetworkingContentDelivery.png) Networking & Content Delivery

## <a name="Service_Amazon Virtual Private Cloud"></a> ![Amazon Virtual Private Cloud](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VirtualPrivateCloud.png) Amazon Virtual Private Cloud

### VPC Requirements

| Requirement | Description |  Default value | Mandatory |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR block | Network size ie. number of available IPs in VPC | 10.1.0.0/18 | yes |
| Availability zones | How many AZs to spread VPC across | 3 (at least 2 for high availability) | yes |
| Private subnets | How many private subnets to create | 3 (at least 2 for high availability; one per each AZ) | yes |
| Public subnets | How many public subnets to create | 3 (at least 2 for high availability; one per each AZ) | yes |
| NAT gateway | Enable/disable NAT in VPC | enable | yes |
| Single NAT gateway | Controls how many NAT gateways/Elastic IPs to provision | enable | no |
| Internet gateway | Enable/disable IGW in VPC | enable | yes |
| DNS hostnames | Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses. | enable | yes |

### <a name="Resource_Internet gateway"></a>![Internet gateway](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VPCInternetGateway.png) Internet gateway
| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <cluster name>-vpc | Internet Gateway for SIMPHERA Virtual Private Network. | Yes |

### <a name="Resource_NAT gateway"></a>![NAT gateway](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VPCNATGateway.png) NAT gateway
| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <cluster name>-vpc-eu-central-1a | NAT Gateway for SIMPHERA Virtual Private Network. | Yes |

### <a name="Resource_Route table"></a>Route table
| Name |
| ---- |
| <cluster name>-vpc-default |
| <cluster name>-vpc-public |
| <cluster name>-vpc-private |

### <a name="Resource_Security group"></a>Security group
<table>
<tr><th>Group name</th><th>Group description</th><th>Direction</th><th>Protocol</th><th>Port range</th><th>Rule description</th></tr>
<tr><td rowspan="1"><cluster name>-db-sg</td><td rowspan="1">PostgreSQL security group</td><td>inbound</td><td>tcp</td><td>5432</td><td>PostgreSQL access from within VPC</td></tr>
<tr><td rowspan="5">eks-cluster-sg-<cluster name>-1760095786</td><td rowspan="5">EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads.</td><td>inbound</td><td>tcp</td><td>30494</td><td>kubernetes.io/rule/nlb/client=a032278f64e794c8698e8cc19a5a3bc6</td></tr><tr><td>inbound</td><td>All</td><td>All</td><td></td></tr><tr><td>inbound</td><td>tcp</td><td>31661</td><td>kubernetes.io/rule/nlb/client=a032278f64e794c8698e8cc19a5a3bc6</td></tr><tr><td>inbound</td><td>icmp</td><td>3 - 4</td><td>kubernetes.io/rule/nlb/mtu</td></tr><tr><td>outbound</td><td>All</td><td>All</td><td></td></tr>
<tr><td rowspan="2"><cluster name>-license-server</td><td rowspan="2">License server security group</td><td>inbound</td><td>tcp</td><td>22350</td><td>Inbound TCP on port 22350 from kubernetes nodes security group</td></tr><tr><td>outbound</td><td>All</td><td>All</td><td>allow all outbound traffic</td></tr>

</table>

### <a name="Resource_Subnet"></a>Subnet
| Name |
| ---- |
| <cluster name>-vpc-public-eu-central-1c |
| <cluster name>-vpc-public-eu-central-1a |
| <cluster name>-vpc-private-eu-central-1b |
| <cluster name>-vpc-public-eu-central-1b |
| <cluster name>-vpc-private-eu-central-1a |
| <cluster name>-vpc-private-eu-central-1c |

### Private subnets requirements

| Requirement | Description |  Default value | Mandatory |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR blocks | Network size, ie number of available IPs per private subnet | 10.1.0.0/22 <br /> 10.1.4.0/22 <br /> 10.1.8.0/22 | yes |
| Tags | Metadata for organizing your AWS resources | "kubernetes.io/cluster/\<cluster name>" = "shared" <br /> "kubernetes.io/role/elb" = "1" <br /> "purpose" = "private" | yes |
| Network Access Lists | Allows or denies specific inbound or outbound traffic at the subnet level | Allow all inbound/outbound | yes |

### Public subnets requirements

| Requirement | Description |  Default value | Mandatory |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR blocks | Network size, ie number of available IPs per public subnet | 10.1.12.0/22 <br /> 10.1.16.0/22 <br /> 10.1.20.0/22 | yes |
| Tags | Metadata for organizing your AWS resources | "kubernetes.io/cluster/\<cluster name>" = "shared" <br /> "kubernetes.io/role/elb" = "1" <br /> "purpose" = "public" | yes |
| Network Access Lists | Allows or denies specific inbound or outbound traffic at the subnet level | Allow all inbound/outbound | yes |

### 'Private' route table requirements

| Requirement | Description |  Default value | Mandatory |
| ----------- | ----------- | -------------- | ---------- |
| Routes | Minimum routes for network communication to work | 0.0.0.0/0 to \<NAT gateway> <br /> \<vpcCidrBlock> to local | yes |
| Subnet associations | Apply route table routes to a particular subnet | Explicit, all private subnets | yes |

### 'Public' route table requirements

| Requirement | Description |  Default value | Mandatory |
| ----------- | ----------- | -------------- | ---------- |
| Routes | Minimum routes for network communication to work | 0.0.0.0/0 to \<Internet gateway> <br /> \<vpcCidrBlock> to local | yes |
| Subnet associations | Apply route table routes to a particular subnet | Explicit, all public subnets | yes |

### <a name="Resource_Virtual Private Cloud"></a>Virtual Private Cloud
| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <cluster name>-vpc | VPC used for deploying resources required by dSPACE cloud products | Yes |

## <a name="Service_Elastic Load Balancing"></a> ![Elastic Load Balancing](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/ElasticLoadBalancing.png) Elastic Load Balancing

### <a name="Resource_Network Load Balancer"></a>![Network Load Balancer](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/ElasticLoadBalancingNetworkLoadBalancer.png) Network Load Balancer
| Description | Mandatory |
| ----------- | --------- |
| Network Load Balancer for EKS created by nginx controller. | Yes |

# <a name="Category_Storage"></a> ![Storage](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/Storage.png) Storage

## <a name="Service_Amazon Simple Storage Service"></a> ![Amazon Simple Storage Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/SimpleStorageService.png) Amazon Simple Storage Service

### <a name="Resource_Bucket"></a>![Bucket](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/SimpleStorageServiceBucket.png) Bucket
| Name | Description | [ACL](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl) | Mandatory |
| ---- | ----------- | ---------- | ---------- |
| <cluster name>-<environment> | Stores binary data like zipped files containing simulation models, test results, vehicle models, etc. | private | Yes |
| <cluster name>-logs | Bucket for storing general logs of infrastructure | private | No |
| <IVS raw data bucket name>-<environment> | IVS recordings | private | No |
| <IVS data bucket name>-<environment> | IVS execution results and static web files | private | No |
| <cluster name>-license-server-bucket | This bucket is used for the initial setup of the license server to transfer several license files securely between an administration PC and the license server | private | No |

# <a name="Category_Analytics"></a> ![Analytics](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Analytics/Analytics.png) Analytics

## <a name="Service_Amazon OpenSearch Service"></a> ![Amazon OpenSearch Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Analytics/OpenSearchService.png) Amazon OpenSearch Service

### <a name="Resource_Domain"></a>Domain
| Name | Mandatory |
| ---- | ---------- |
| <cluster name>-<instance environment> | No |

# <a name="Category_Security, Identity, & Compliance"></a> ![Security, Identity, & Compliance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/SecurityIdentityCompliance.png) Security, Identity, & Compliance

## <a name="Service_AWS Key Management Service"></a> ![AWS Key Management Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/KeyManagementService.png) AWS Key Management Service

### <a name="Resource_Customer managed keys"></a>Customer managed keys
| Description | Mandatory |
| ----------- | ---------- |
| EKS cluster secret encryption key | Yes |

# ![Security, Identity, & Compliance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/SecurityIdentityCompliance.png) Security, Identity, & Compliance

## ![AWS Identity and Access Management](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityandAccessManagement.png) AWS Identity and Access Management

### ![Role](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementRole.png) Role
| Role name | Description | Policies  |
| --------- | ----------- | --------- |
|<environment>-executoragentlinux||<ul><li>[<cluster name>-<environment>-s3-policy](#<cluster name>-<environment>-s3-policy)</li></ul>|
|<environment>-rds-enhanced-monitoring||<ul><li>[AmazonRDSEnhancedMonitoringRole](#AmazonRDSEnhancedMonitoringRole)</li></ul>|
|<cluster name>-aws-node-irsa|AWS IAM Role for the Kubernetes service account aws-node.|<ul><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li></ul>|
|<cluster name>-cluster-autoscaler-sa-irsa|AWS IAM Role for the Kubernetes service account cluster-autoscaler-sa.|<ul><li>[<cluster name>-cluster-autoscaler-irsa](#<cluster name>-cluster-autoscaler-irsa)</li></ul>|
|<cluster name>-cluster-role||<ul><li>[AmazonEKSClusterPolicy](#AmazonEKSClusterPolicy)</li><li>[AmazonEKSVPCResourceController](#AmazonEKSVPCResourceController)</li><li><cluster name>-cluster-role</li></ul>|
|<cluster name>-default|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|<cluster name>-ebs-csi-controller-irsa|AWS IAM Role for the Kubernetes service account ebs-csi-controller-sa.|<ul><li>[AmazonEBSCSIDriverPolicy](#AmazonEBSCSIDriverPolicy)</li></ul>|
|<cluster name>-efs-csi-controller-irsa|AWS IAM Role for the Kubernetes service account efs-csi-controller-sa.|<ul><li>[AmazonEFSCSIDriverPolicy](#AmazonEFSCSIDriverPolicy)</li></ul>|
|<cluster name>-execnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|<cluster name>-flowlogs-role||<ul><li>[<cluster name>-flowlogs-policy](#<cluster name>-flowlogs-policy)</li></ul>|
|<cluster name>-gpuexecnodes-<driver version>|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li></ul>|
|<cluster name>-gpuivsnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|<cluster name>-license-server-role|IAM role used for the license server instance profile.|<ul><li>[<cluster name>-license-server-policy](#<cluster name>-license-server-policy)</li><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li></ul>|
|<cluster name>-<instance environment>-ivs-sa-role||<ul><li><cluster name>-<instance environment>-ivs-sa-access-policy</li></ul>|
|<cluster name>-s3-csi-driver-irsa|AWS IAM Role for the Kubernetes service account s3-csi-driver-sa.|<ul><li>[Amazons3CSIDriverPolicy](#Amazons3CSIDriverPolicy)</li></ul>|
|<cluster name>-<environment>-s3-role|IAM role for the MinIO service account|<ul><li>[<cluster name>-<environment>-s3-policy](#<cluster name>-<environment>-s3-policy)</li></ul>|
|<cluster name>-winexecnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li></ul>|

### ![Policies](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementPermissions.png) Policies
| Policy name | Description | Managed By |
| ----------- | ----------- | ---------- |
|<a name="<cluster name>-<environment>-s3-policy"></a>[<cluster name>-<environment>-s3-policy](./)|Allows access to S3 bucket.|Customer|
|<a name="AmazonRDSEnhancedMonitoringRole"></a>[AmazonRDSEnhancedMonitoringRole](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonRDSEnhancedMonitoringRole)|Provides access to Cloudwatch for RDS Enhanced Monitoring|AWS|
|<a name="AmazonEKS_CNI_Policy"></a>[AmazonEKS_CNI_Policy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKS_CNI_Policy)|This policy provides the Amazon VPC CNI Plugin (amazon-vpc-cni-k8s) the permissions it requires to modify the IP address configuration on your EKS worker nodes. This permission set allows the CNI to list, describe, and modify Elastic Network Interfaces on your behalf. More information on the AWS VPC CNI Plugin is available here: https://github.com/aws/amazon-vpc-cni-k8s|AWS|
|<a name="<cluster name>-cluster-autoscaler-irsa"></a>[<cluster name>-cluster-autoscaler-irsa](./)|Cluster Autoscaler IAM policy|Customer|
|<a name="AmazonEKSClusterPolicy"></a>[AmazonEKSClusterPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSClusterPolicy)|This policy provides Kubernetes the permissions it requires to manage resources on your behalf. Kubernetes requires Ec2:CreateTags permissions to place identifying information on EC2 resources including but not limited to Instances, Security Groups, and Elastic Network Interfaces. |AWS|
|<a name="AmazonEKSVPCResourceController"></a>[AmazonEKSVPCResourceController](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSVPCResourceController)|Policy used by VPC Resource Controller to manage ENI and IPs for worker nodes.|AWS|
|<a name="AmazonSSMManagedInstanceCore"></a>[AmazonSSMManagedInstanceCore](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonSSMManagedInstanceCore)|The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality.|AWS|
|<a name="AmazonEC2ContainerRegistryReadOnly"></a>[AmazonEC2ContainerRegistryReadOnly](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEC2ContainerRegistryReadOnly)|Provides read-only access to Amazon EC2 Container Registry repositories.|AWS|
|<a name="AmazonEKSWorkerNodePolicy"></a>[AmazonEKSWorkerNodePolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSWorkerNodePolicy)|This policy allows Amazon EKS worker nodes to connect to Amazon EKS Clusters.|AWS|
|<a name="AmazonEBSCSIDriverPolicy"></a>[AmazonEBSCSIDriverPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEBSCSIDriverPolicy)|IAM Policy that allows the CSI driver service account to make calls to related services such as EC2 on your behalf.|AWS|
|<a name="AmazonEFSCSIDriverPolicy"></a>[AmazonEFSCSIDriverPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEFSCSIDriverPolicy)|Provides management access to EFS resources and read access to EC2|AWS|
|<a name="<cluster name>-flowlogs-policy"></a>[<cluster name>-flowlogs-policy](./)||Customer|
|<a name="<cluster name>-license-server-policy"></a>[<cluster name>-license-server-policy](./)|Allows access to S3 bucket and Secure Session Manager connections.|Customer|
|<a name="Amazons3CSIDriverPolicy"></a>[Amazons3CSIDriverPolicy](./)|Amazons3CSIDriverPolicy|Customer|