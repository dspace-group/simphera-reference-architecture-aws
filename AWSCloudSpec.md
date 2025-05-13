# ![Compute](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/Compute.png) Compute

## ![Amazon Elastic Compute Cloud](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2.png) Amazon Elastic Compute Cloud

### ![EC2 Instance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2Instance.png) EC2 Instance

| AMI Name | Platform | Description | Mandatory |
| -------- | -------- | ----------- | --------- |
| amazon-eks-node | Linux/UNIX | Default node pool instances (auto-scaled) | Yes |
| amazon-eks-node | Linux/UNIX | Execution node pool instances (auto-scaled) | No |
| Windows_Server-2022-English-Core-EKS_Optimized | Windows | Windows Execution node pool instances (auto-scaled) | No |
| ubuntu-eks/k8s_<k8s version>/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server | Linux/UNIX | GPU Execution node pool instances (auto-scaled) | No |
| amzn2-ami-hvm-2.0.20210813.1-x86_64-gp2 | Amazon Linux  | dSPACE license server  | No |

### ![Elastic IP address](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2ElasticIPAddress.png) Elastic IP address

| Description |
| ----------- |
| Elastic IP Address for NAT Gateway |

### Launch template

| Name | Mandatory |
| ---- | ---------- |
| Launch template for default node pool. | Yes |
| Launch template for execution node pool. | No |
| Launch template for GPU execution node pool. | No |
| Launch template for IVS GPU execution node pool. | No |
| Launch template for IVS WIndows execution node pool. | No |

## ![Amazon EC2 Auto Scaling](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2AutoScaling.png) Amazon EC2 Auto Scaling

### Auto Scaling Group

| Name | Mandatory |
| ---- | --------- |
| Auto scaling group for default node pool. | Yes |
| Auto scaling group for execution node pool. | No |
| Auto scaling group for GPU execution node pool. | No |
| Auto scaling group for IVS GPU execution node pool. | No |
| Auto scaling group for IVS WIndows execution node pool. | No |

# ![Containers](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/Containers.png) Containers

## ![Amazon Elastic Kubernetes Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/ElasticKubernetesService.png) Amazon Elastic Kubernetes Service

### Cluster

| Name | Description |
| ---- | ----------- |
| <_cluster name_> | EKS Kubernetes cluster |

### Add-on

| Name | Mandatory |
| ---- | ---------- |
| vpc-cni | Yes |
| kube-proxy | Yes |
| coredns | No |
| aws-ebs-csi-driver | No |
| aws-efs-csi-driver | No |
| aws-mountpoint-s3-csi-driver | No |

### Node group

| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <_cluster name_>-default | Node group for default node pool. | Yes |
| <_cluster name_>-execnodes | Node group for execution node pool. | No |
| <_cluster name_>-gpuexecnodes-<driver version> | Node group for GPU execution node pool. | No |
| <_cluster name_>-gpuivsnodes | Node group for IVS GPU execution node pool. | No |
| <_cluster name_>-winexecnodes | Node group for IVS WIndows execution node pool. | No |

# ![Database](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/Database.png) Database

## ![Amazon Relational Database](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/RDS.png) Amazon Relational Database

### ![PostgreSQL instance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/AuroraPostgreSQLInstance.png) PostgreSQL instance

| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <_cluster name_>-<_environment_>-simphera | Store data records of items like projects, test suites, etc. | Yes |
| <_cluster name_>-<_environment_>-keycloak | Keycloak stores SIMPHERA users in a separate Amazon RDS PostgreSQL instance. | Yes |

### Subnet group

| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <_cluster name_>-<_environment_>-vpc | Amazon Relational Database subnet group used for simphera and keycloak database instances | Yes |

# ![Management & Governance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/ManagementGovernance.png) Management & Governance

## ![Amazon CloudWatch](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatch.png) Amazon CloudWatch

### ![Log groups](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatchLogs.png) Log groups

| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| /aws/eks/<_cluster name_>/cluster | Node metrics and Kubernetes system logs. | No |
| /aws/rds/instance/<_cluster name_>-<_environment_>-keycloak/postgresql | Keycloak database logs. | No |
| /aws/rds/instance/<_cluster name_>-<_environment_>-simphera/postgresql | Simphera database logs | No |
| /aws/vpc/<_cluster name_> | VPC logs | No |
| /aws/ssm/<_cluster name_>/scan | EC2 scan maintenance logs | No |
| /aws/ssm/<_cluster name_>/install | EC2 maintenance installation logs | No |

# ![Networking & Content Delivery](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/NetworkingContentDelivery.png) Networking & Content Delivery

## ![Amazon Virtual Private Cloud](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VirtualPrivateCloud.png) Amazon Virtual Private Cloud

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

### ![Internet gateway](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VPCInternetGateway.png) Internet gateway

| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <_cluster name_>-vpc | Internet Gateway for SIMPHERA Virtual Private Network. | Yes |

### ![NAT gateway](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VPCNATGateway.png) NAT gateway

| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <_cluster name_>-vpc-eu-central-1a | NAT Gateway for SIMPHERA Virtual Private Network. | Yes |

### Route table

| Name |
| ---- |
| <_cluster name_>-vpc-default |
| <_cluster name_>-vpc-public |
| <_cluster name_>-vpc-private |

### Security group

<table>
<tr><th>Group name</th><th>Group description</th><th>Direction</th><th>Protocol</th><th>Port range</th><th>Rule description</th></tr>
<tr><td rowspan="1">&lt;<i>cluster name</i>&gt;-db-sg </td><td rowspan="1">PostgreSQL security group</td><td>inbound</td><td>tcp</td><td>5432</td><td>PostgreSQL access from within VPC</td></tr>
<tr><td rowspan="5">eks-cluster-sg-&lt;<i>cluster name</i>&gt;-1760095786</td><td rowspan="5">EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads.</td><td>inbound</td><td>tcp</td><td>30494</td><td>kubernetes.io/rule/nlb/client=a032278f64e794c8698e8cc19a5a3bc6</td></tr><tr><td>inbound</td><td>All</td><td>All</td><td></td></tr><tr><td>inbound</td><td>tcp</td><td>31661</td><td>kubernetes.io/rule/nlb/client=a032278f64e794c8698e8cc19a5a3bc6</td></tr><tr><td>inbound</td><td>icmp</td><td>3 - 4</td><td>kubernetes.io/rule/nlb/mtu</td></tr><tr><td>outbound</td><td>All</td><td>All</td><td></td></tr>
<tr><td rowspan="2">&lt;<i>cluster name</i>&gt;-license-server</td><td rowspan="2">License server security group</td><td>inbound</td><td>tcp</td><td>22350</td><td>Inbound TCP on port 22350 from kubernetes nodes security group</td></tr><tr><td>outbound</td><td>All</td><td>All</td><td>allow all outbound traffic</td></tr>

</table>

### Subnet

| Name |
| ---- |
| <_cluster name_>-vpc-public-eu-central-1c |
| <_cluster name_>-vpc-public-eu-central-1a |
| <_cluster name_>-vpc-private-eu-central-1b |
| <_cluster name_>-vpc-public-eu-central-1b |
| <_cluster name_>-vpc-private-eu-central-1a |
| <_cluster name_>-vpc-private-eu-central-1c |

### Private subnets requirements

| Requirement | Description |  Default value | Mandatory |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR blocks | Network size, ie number of available IPs per private subnet | 10.1.0.0/22 <br/> 10.1.4.0/22 <br /> 10.1.8.0/22 | yes |
| Tags | Metadata for organizing your AWS resources | "kubernetes.io/cluster/\<_cluster name_>" = "shared" <br /> "kubernetes.io/role/elb" = "1" <br /> "purpose" = "private" | yes |
| Network Access Lists | Allows or denies specific inbound or outbound traffic at the subnet level | Allow all inbound/outbound | yes |

### Public subnets requirements

| Requirement | Description |  Default value | Mandatory |
| ----------- | ----------- | -------------- | ---------- |
| IPv4 CIDR blocks | Network size, ie number of available IPs per public subnet | 10.1.12.0/22 <br /> 10.1.16.0/22 <br /> 10.1.20.0/22 | yes |
| Tags | Metadata for organizing your AWS resources | "kubernetes.io/cluster/\<_cluster name_>" = "shared" <br /> "kubernetes.io/role/elb" = "1" <br /> "purpose" = "public" | yes |
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

### Virtual Private Cloud

| Name | Description | Mandatory |
| ---- | ----------- | ---------- |
| <_cluster name_>-vpc | VPC used for deploying resources required by dSPACE cloud products | Yes |

## ![Elastic Load Balancing](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/ElasticLoadBalancing.png) Elastic Load Balancing

### ![Network Load Balancer](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/ElasticLoadBalancingNetworkLoadBalancer.png) Network Load Balancer

| Description | Mandatory |
| ----------- | --------- |
| Network Load Balancer for EKS created by nginx controller. | Yes |

# ![Storage](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/Storage.png) Storage

## ![Amazon Simple Storage Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/SimpleStorageService.png) Amazon Simple Storage Service

### ![Bucket](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/SimpleStorageServiceBucket.png) Bucket

| Name | Description | [ACL](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl) | Mandatory |
| ---- | ----------- | ---------- | ---------- |
| <_cluster name_>-<_environment_> | Stores binary data like zipped files containing simulation models, test results, vehicle models, etc. | private | Yes |
| <_cluster name_>-logs | Bucket for storing general logs of infrastructure | private | No |
| <_IVS raw data bucket name_>-<_environment_> | IVS recordings | private | No |
| <_IVS data bucket name_>-<_environment_> | IVS execution results and static web files | private | No |
| <_cluster name_>-license-server-bucket | This bucket is used for the initial setup of the license server to transfer several license files securely between an administration PC and the license server | private | No |

# ![Analytics](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Analytics/Analytics.png) Analytics

## ![Amazon OpenSearch Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Analytics/OpenSearchService.png) Amazon OpenSearch Service

### Domain

| Name | Mandatory |
| ---- | ---------- |
| <_cluster name_>-<_instance environment_> | No |

# ![Security, Identity, & Compliance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/SecurityIdentityCompliance.png) Security, Identity, & Compliance

## ![AWS Key Management Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/KeyManagementService.png) AWS Key Management Service

### Customer managed keys

| Description | Mandatory |
| ----------- | ---------- |
| EKS cluster secret encryption key | Yes |

## ![AWS Identity and Access Management](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityandAccessManagement.png) AWS Identity and Access Management

### ![Role](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementRole.png) Role

| Role name | Description | Policies  |
| --------- | ----------- | --------- |
|<_environment_>-executoragentlinux||<ul><li>[<_cluster name_>-<_environment_>-s3-policy](#<_cluster name_>-<_environment_>-s3-policy)</li></ul>|
|<_environment_>-rds-enhanced-monitoring||<ul><li>[AmazonRDSEnhancedMonitoringRole](#AmazonRDSEnhancedMonitoringRole)</li></ul>|
|<_cluster name_>-aws-node-irsa|AWS IAM Role for the Kubernetes service account aws-node.|<ul><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li></ul>|
|<_cluster name_>-cluster-autoscaler-sa-irsa|AWS IAM Role for the Kubernetes service account cluster-autoscaler-sa.|<ul><li>[<_cluster name_>-cluster-autoscaler-irsa](#<_cluster name_>-cluster-autoscaler-irsa)</li></ul>|
|<_cluster name_>-cluster-role||<ul><li>[AmazonEKSClusterPolicy](#AmazonEKSClusterPolicy)</li><li>[AmazonEKSVPCResourceController](#AmazonEKSVPCResourceController)</li><li><_cluster name_>-cluster-role</li></ul>|
|<_cluster name_>-default|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|<_cluster name_>-ebs-csi-controller-irsa|AWS IAM Role for the Kubernetes service account ebs-csi-controller-sa.|<ul><li>[AmazonEBSCSIDriverPolicy](#AmazonEBSCSIDriverPolicy)</li></ul>|
|<_cluster name_>-efs-csi-controller-irsa|AWS IAM Role for the Kubernetes service account efs-csi-controller-sa.|<ul><li>[AmazonEFSCSIDriverPolicy](#AmazonEFSCSIDriverPolicy)</li></ul>|
|<_cluster name_>-execnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|<_cluster name_>-flowlogs-role||<ul><li>[<_cluster name_>-flowlogs-policy](#<_cluster name_>-flowlogs-policy)</li></ul>|
|<_cluster name_>-gpuexecnodes-<driver version>|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li></ul>|
|<_cluster name_>-gpuivsnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>s3-access-policy</li></ul>|
|<_cluster name_>-license-server-role|IAM role used for the license server instance profile.|<ul><li>[<_cluster name_>-license-server-policy](#<_cluster name_>-license-server-policy)</li><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li></ul>|
|<_cluster name_>-<_instance environment_>-ivs-sa-role||<ul><li><_cluster name_>-<_instance environment_>-ivs-sa-access-policy</li></ul>|
|<_cluster name_>-s3-csi-driver-irsa|AWS IAM Role for the Kubernetes service account s3-csi-driver-sa.|<ul><li>[Amazons3CSIDriverPolicy](#Amazons3CSIDriverPolicy)</li></ul>|
|<_cluster name_>-<_environment_>-s3-role|IAM role for the MinIO service account|<ul><li>[<_cluster name_>-<_environment_>-s3-policy](#<_cluster name_>-<_environment_>-s3-policy)</li></ul>|
|<_cluster name_>-winexecnodes|EKS Managed Node group IAM Role|<ul><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li></ul>|

### ![Policies](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementPermissions.png) Policies

| Policy name | Description | Managed By |
| ----------- | ----------- | ---------- |
|<a name="<_cluster name_>-<_environment_>-s3-policy"></a>[<_cluster name_>-<_environment_>-s3-policy](./)|Allows access to S3 bucket.|Customer|
|<a name="AmazonRDSEnhancedMonitoringRole"></a>[AmazonRDSEnhancedMonitoringRole](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonRDSEnhancedMonitoringRole)|Provides access to Cloudwatch for RDS Enhanced Monitoring|AWS|
|<a name="AmazonEKS_CNI_Policy"></a>[AmazonEKS_CNI_Policy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKS_CNI_Policy)|This policy provides the Amazon VPC CNI Plugin (amazon-vpc-cni-k8s) the permissions it requires to modify the IP address configuration on your EKS worker nodes. This permission set allows the CNI to list, describe, and modify Elastic Network Interfaces on your behalf. More information on the AWS VPC CNI Plugin is available here: <https://github.com/aws/amazon-vpc-cni-k8s>|AWS|
|<a name="<_cluster name_>-cluster-autoscaler-irsa"></a>[<_cluster name_>-cluster-autoscaler-irsa](./)|Cluster Autoscaler IAM policy|Customer|
|<a name="AmazonEKSClusterPolicy"></a>[AmazonEKSClusterPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSClusterPolicy)|This policy provides Kubernetes the permissions it requires to manage resources on your behalf. Kubernetes requires Ec2:CreateTags permissions to place identifying information on EC2 resources including but not limited to Instances, Security Groups, and Elastic Network Interfaces. |AWS|
|<a name="AmazonEKSVPCResourceController"></a>[AmazonEKSVPCResourceController](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSVPCResourceController)|Policy used by VPC Resource Controller to manage ENI and IPs for worker nodes.|AWS|
|<a name="AmazonSSMManagedInstanceCore"></a>[AmazonSSMManagedInstanceCore](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonSSMManagedInstanceCore)|The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality.|AWS|
|<a name="AmazonEC2ContainerRegistryReadOnly"></a>[AmazonEC2ContainerRegistryReadOnly](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEC2ContainerRegistryReadOnly)|Provides read-only access to Amazon EC2 Container Registry repositories.|AWS|
|<a name="AmazonEKSWorkerNodePolicy"></a>[AmazonEKSWorkerNodePolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSWorkerNodePolicy)|This policy allows Amazon EKS worker nodes to connect to Amazon EKS Clusters.|AWS|
|<a name="AmazonEBSCSIDriverPolicy"></a>[AmazonEBSCSIDriverPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEBSCSIDriverPolicy)|IAM Policy that allows the CSI driver service account to make calls to related services such as EC2 on your behalf.|AWS|
|<a name="AmazonEFSCSIDriverPolicy"></a>[AmazonEFSCSIDriverPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEFSCSIDriverPolicy)|Provides management access to EFS resources and read access to EC2|AWS|
|<a name="<_cluster name_>-flowlogs-policy"></a>[<_cluster name_>-flowlogs-policy](./)||Customer|
|<a name="<_cluster name_>-license-server-policy"></a>[<_cluster name_>-license-server-policy](./)|Allows access to S3 bucket and Secure Session Manager connections.|Customer|
|<a name="Amazons3CSIDriverPolicy"></a>[Amazons3CSIDriverPolicy](./)|Amazons3CSIDriverPolicy|Customer|
