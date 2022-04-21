# <a name="CategoryCompute"></a> ![Compute](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/Compute.png) Compute

## <a name="ServiceEC2"></a> ![Amazon Elastic Compute Cloud](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2.png) Amazon Elastic Compute Cloud

### <a name="ResourceEC2Instance"></a>![EC2 Instance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2Instance.png) EC2 Instance
| AMI Name | Platform | Description | Mandatory |
| -------- | -------- | ----------- | --------- |
| amazon-eks-node | Linux/UNIX | Default node pool instances (auto-scaled) | Yes |
| amazon-eks-node | Linux/UNIX | Execution node pool instances (auto-scaled). The default instance type for the execution node pool is t3.medium. Running a large number of simulations in parallel may exceed the maximum number of vCPUs limited in the service quota `Running On-Demand All Standard (A, C, D, H, I, M, R, T, Z) instances`. | No |
| amzn2-ami-hvm-2.0.20210813.1-x86_64-gp2 | Amazon Linux  | dSPACE license server  | No |


### <a name="ResourceEC2ElasticIPAddress"></a>![Elastic IP address](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2ElasticIPAddress.png) Elastic IP address
| Description |
| ----------- |
| Elastic IP Address for NAT Gateway | 

### <a name="ResourceLaunchTemplate"></a>Launch template
| Name | Mandatory |
| ---- | --------- |
| Launch template for default node pool. | Yes |
| Launch template for execution node pool. | No |

## <a name="ServiceEC2AutoScaling"></a> ![Amazon EC2 Auto Scaling](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Compute/EC2AutoScaling.png) Amazon EC2 Auto Scaling

### <a name="ResourceAutoScalingGroup"></a> Auto Scaling Group
| Name | Mandatory |
| ---- | --------- |
| Auto scaling group for default node pool. | Yes |
| Auto scaling group for execution node pool. | No |

# <a name="CategoryContainers"></a> ![Containers](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/Containers.png) Containers

## <a name="ServiceElasticKubernetesService"></a> ![Amazon Elastic Kubernetes Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/ElasticKubernetesService.png) Amazon Elastic Kubernetes Service


### <a name="ResourceCluster"></a>Cluster
| Name | Description | Mandatory |
| ---- | ----------- | --------- |
| &lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks | Kubernetes cluster for SIMPHERA. | Yes |

### <a name="ResourceNodeGroup"></a>Node group
| Description | Mandatory |
| ----------- | --------- |
| Node group for SIMPHERA services and other auxiliary third-party services like Keycloak, nginx, etc. | Yes |
| Node group for the executors that perform the testing of the system under test. | No |

# <a name="CategoryDatabase"></a> ![Database](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/Database.png) Database

## <a name="ServiceRDS"></a> ![Amazon Relational Database](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/RDS.png) Amazon Relational Database

### <a name="ResourcePostgreSQLInstance"></a>![PostgreSQL instance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/AuroraPostgreSQLInstance.png) PostgreSQL instance
| Name | Description | Mandatory |
| ---- | ----------- | --------- |
| &lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-simphera | Store data records of items like projects, test suites, etc. | Yes |
| &lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-keycloak | Keycloak stores SIMPHERA users in a separate Amazon RDS PostgreSQL instance. | Yes |

# <a name="CategoryManagementGovernance"></a> ![Management & Governance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/ManagementGovernance.png) Management & Governance
## <a name="ServiceCloudWatch"></a> ![Amazon CloudWatch](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatch.png) Amazon CloudWatch
### <a name="ResourceCloudWatchLogs"></a>![Log groups](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatchLogs.png) Log groups
| Name | Description |
| ---- | ----------- |
| /aws/eks/&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks/cluster | Node metrics and Kubernetes system logs. |
| /&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks/worker-fluentbit-logs | EKS container logs. |

# <a name="CategoryNetworkingContentDelivery"></a> ![Networking & Content Delivery](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/NetworkingContentDelivery.png) Networking & Content Delivery

## <a name="ServiceVirtualPrivateCloud"></a> ![Amazon Virtual Private Cloud](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VirtualPrivateCloud.png) Amazon Virtual Private Cloud

### <a name="ResourceInternetGateway"></a>![Internet gateway](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VPCInternetGateway.png) Internet gateway
| Description |
| ----------- |
| Internet Gateway for SIMPHERA Virtual Private Network. |

### <a name="ResourceNATGateway"></a>![NAT gateway](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/VPCNATGateway.png) NAT gateway
| Description |
| ----------- |
| NAT Gateway for SIMPHERA Virtual Private Network. |

### <a name="ResourceSecurityGroup"></a>Security group
<table>
    <tr>
        <th>Group name</th>
        <th>Group description</th>
        <th>Direction</th>
        <th>Protocol</th>
        <th>Port range</th>
        <th>Rule description</th>
    </tr>
    <tr>
        <td rowspan="5">eks-cluster-sg-&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks></td>
        <td rowspan="5">EKS created security group applied to ENI that is attached to EKS Control Plane master nodes,
            as well as any managed workloads.</td>
        <td>inbound</td>
        <td>tcp</td>
        <td>30128</td>
        <td><a
                href="https://kubernetes.io/docs/concepts/services-networking/_print/#aws-nlb-support">kubernetes.io/rule/nlb/health</a>
        </td>
    </tr>
    <tr>
        <td>inbound</td>
        <td>All</td>
        <td>All</td>
        <td></td>
    </tr>
    <tr>
        <td>inbound</td>
        <td>tcp</td>
        <td>30804</td>
        <td><a
                href="https://kubernetes.io/docs/concepts/services-networking/_print/#aws-nlb-support">kubernetes.io/rule/nlb/health</a>
        </td>
    </tr>
    <tr>
        <td>inbound</td>
        <td>icmp</td>
        <td>3 - 4</td>
        <td><a
                href="https://kubernetes.io/docs/concepts/services-networking/_print/#aws-nlb-support">kubernetes.io/rule/nlb/mtu</a>
        </td>
    </tr>
    <tr>
        <td>outbound</td>
        <td>All</td>
        <td>All</td>
        <td></td>
    </tr>
    <tr>
        <td rowspan="2">default</td>
        <td rowspan="2">default VPC security group</td>
        <td>inbound</td>
        <td>All</td>
        <td>All</td>
        <td></td>
    </tr>
    <tr>
        <td>outbound</td>
        <td>All</td>
        <td>All</td>
        <td></td>
    </tr>
    <tr>
        <td rowspan="1">&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-db-sg</td>
        <td rowspan="1">PostgreSQL security group</td>
        <td>inbound</td>
        <td>tcp</td>
        <td>5432</td>
        <td>PostgreSQL access from within VPC</td>
    </tr>
    <tr>
        <td rowspan="4">&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-eks_worker_sg</td>
        <td rowspan="4">Security group for all nodes in the cluster.</td>
        <td>inbound</td>
        <td>All</td>
        <td>All</td>
        <td>Allow node to communicate with each other.</td>
    </tr>
    <tr>
        <td>inbound</td>
        <td>tcp</td>
        <td>1025 - 65535</td>
        <td>Allow workers pods to receive communication from the cluster control plane.</td>
    </tr>
    <tr>
        <td>inbound</td>
        <td>tcp</td>
        <td>443</td>
        <td>Allow pods running extension API servers on port 443 to receive communication from cluster control plane.
        </td>
    </tr>
    <tr>
        <td>outbound</td>
        <td>All</td>
        <td>All</td>
        <td>Allow nodes all egress to the Internet.</td>
    </tr>
    <tr>
        <td rowspan="2">&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-eks_cluster_sg</td>
        <td rowspan="2">EKS cluster security group.</td>
        <td>inbound</td>
        <td>tcp</td>
        <td>443</td>
        <td>Allow pods to communicate with the EKS cluster API.</td>
    </tr>
    <tr>
        <td>outbound</td>
        <td>All</td>
        <td>All</td>
        <td>Allow cluster egress access to the Internet.</td>
    </tr>
</table>


### <a name="ResourceSubnet"></a>Subnet
| Name | 
| ---- | 
| Public subnet in region 1 zone a | 
| Public subnet in region 1 zone b | 
| Public subnet in region 1 zone c |
| Private subnet in region 1 zone a | 
| Private subnet in region 1 zone b | 
| Private subnet in region 1 zone c | 
| Database subnet in region 1 zone a | 
| Database subnet in region 1 zone b | 
| Database subnet in region 1 zone c | 


### <a name="ResourceVirtualPrivateCloud"></a>Virtual Private Cloud
| Name | Mandatory |
| ---- | ---------- |
| Virtual network for SIMPHERA. | Yes |

## <a name="ServiceElasticLoadBalancing"></a> ![Elastic Load Balancing](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/ElasticLoadBalancing.png) Elastic Load Balancing

### <a name="ResourceElasticLoadBalancingNetworkLoadBalancer"></a>![Network Load Balancer](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/NetworkingContentDelivery/ElasticLoadBalancingNetworkLoadBalancer.png) Network Load Balancer
| Description | Mandatory |
| ----------- | --------- |
| Network Load Balancer for EKS created by nginx controller. | Yes |

# <a name="CategoryStorage"></a> ![Storage](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/Storage.png) Storage

## <a name="ServiceSimpleStorageService"></a> ![Amazon Simple Storage Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/SimpleStorageService.png) Amazon Simple Storage Service

### <a name="ResourceBucket"></a>![Bucket](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/SimpleStorageServiceBucket.png) Bucket

| Name | Description | [ACL](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl) | Mandatory |
| ---- | ----------- | ----| --------- |
| &lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt; | Stores binary data like zipped files containing simulation models, test results, vehicle models, etc. | private | Yes |
| &lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-license-server | This bucket is used for the initial setup of the license server to transfer several license files securely between an administration PC and the license server  | private | No |

## <a name="ServiceAmazonElasticBlockStore"></a> ![Amazon Elastic Block Store](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/ElasticBlockStore.png) Amazon Elastic Block Store 

# <a name="ResourceVolume"></a> ![Volume](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Storage/ElasticBlockStoreVolume.png) Volume

| Description | Mandatory |
| ----------- | --------- |
| Volume attached to the license server EC2 | No |
| Kubernetes Persistent Volumes CouchDB nodes (deprecated) | No |

# <a name="CategorySecurityIdentityCompliance"></a> ![Security, Identity, & Compliance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/SecurityIdentityCompliance.png) Security, Identity, & Compliance

## <a name="ServiceKeyManagementService"></a> ![AWS Key Management Service](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/KeyManagementService.png) AWS Key Management Service

### <a name="ResourceManagedKeys"></a>Customer managed keys
| Description | Mandatory |
| ----------- | --------- |
| EKS cluster secret encryption key | No |
| EKS Workers FluentBit CloudWatch Log group KMS Key | No |

## <a name="ServiceIdentityandAccessManagement"></a> ![AWS Identity and Access Management](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityandAccessManagement.png) AWS Identity and Access Management

### <a name="ResourceRole"></a> ![Role](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementRole.png) Role
| Role name | Description | Policies  |
| --------- | ----------- | --------- | 
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-aws-for-fluent-bit-sa-irsa|AWS IAM Role for the Kubernetes service account aws-for-fluent-bit-sa.|<ul><li>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-fluentbit](#&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-fluentbit)</li></ul>|
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-aws-node-irsa|AWS IAM Role for the Kubernetes service account aws-node.|<ul><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li></ul>|
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-cluster-autoscaler-sa-irsa|AWS IAM Role for the Kubernetes service account cluster-autoscaler-sa.|<ul><li>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-cluster-autoscaler-irsa](#&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-cluster-autoscaler-irsa)</li></ul>|
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-cluster-role||<ul><li>[AmazonEKSClusterPolicy](#AmazonEKSClusterPolicy)</li><li>[AmazonEKSServicePolicy](#AmazonEKSServicePolicy)</li><li>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-elb-sl-role-creation20220328154446563700000001](#&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-elb-sl-role-creation20220328154446563700000001)</li><li>[AmazonEKSVPCResourceController](#AmazonEKSVPCResourceController)</li></ul>|
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-default||<ul><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li></ul>|
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-execnodes||<ul><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonSSMManagedInstanceCore](#AmazonSSMManagedInstanceCore)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li></ul>|
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-ingress-nginx-sa-irsa|AWS IAM Role for the Kubernetes service account ingress-nginx-sa.|<ul><li>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-ingress-nginx-sa-policy](#&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-ingress-nginx-sa-policy)</li></ul>|
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks20220328155518107300000008||<ul><li>[AmazonEKSWorkerNodePolicy](#AmazonEKSWorkerNodePolicy)</li><li>[AmazonEC2ContainerRegistryReadOnly](#AmazonEC2ContainerRegistryReadOnly)</li><li>[AmazonEKS_CNI_Policy](#AmazonEKS_CNI_Policy)</li></ul>|
|&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-s3-role|IAM role for the MinIO service account|<ul><li>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-s3-policy](#&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-s3-policy)</li></ul>|

### <a name="ResourcePolicy"></a> ![Policy](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementPermissions.png) Policy
| Policy name | Description | Managed By |
| ----------- | ----------- | ---------- | 
|<a name="&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-fluentbit"></a>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-fluentbit](./)|IAM Policy for AWS for FluentBit|Customer|
|<a name="AmazonEKS_CNI_Policy"></a>[AmazonEKS_CNI_Policy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKS_CNI_Policy)|This policy provides the Amazon VPC CNI Plugin (amazon-vpc-cni-k8s) the permissions it requires to modify the IP address configuration on your EKS worker nodes. This permission set allows the CNI to list, describe, and modify Elastic Network Interfaces on your behalf. More information on the AWS VPC CNI Plugin is available here: https://github.com/aws/amazon-vpc-cni-k8s|AWS|
|<a name="&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-cluster-autoscaler-irsa"></a>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-cluster-autoscaler-irsa](./)|Cluster Autoscaler IAM policy|Customer|
|<a name="AmazonEKSClusterPolicy"></a>[AmazonEKSClusterPolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSClusterPolicy)|This policy provides Kubernetes the permissions it requires to manage resources on your behalf. Kubernetes requires Ec2:CreateTags permissions to place identifying information on EC2 resources including but not limited to Instances, Security Groups, and Elastic Network Interfaces. |AWS|
|<a name="AmazonEKSServicePolicy"></a>[AmazonEKSServicePolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSServicePolicy)|This policy allows Amazon Elastic Container Service for Kubernetes to create and manage the necessary resources to operate EKS Clusters.|AWS|
|<a name="&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-elb-sl-role-creation20220328154446563700000001"></a>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-elb-sl-role-creation20220328154446563700000001](./)|Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role|Customer|
|<a name="AmazonEKSVPCResourceController"></a>[AmazonEKSVPCResourceController](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSVPCResourceController)|Policy used by VPC Resource Controller to manage ENI and IPs for worker nodes.|AWS|
|<a name="AmazonEKSWorkerNodePolicy"></a>[AmazonEKSWorkerNodePolicy](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEKSWorkerNodePolicy)|This policy allows Amazon EKS worker nodes to connect to Amazon EKS Clusters.|AWS|
|<a name="AmazonEC2ContainerRegistryReadOnly"></a>[AmazonEC2ContainerRegistryReadOnly](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonEC2ContainerRegistryReadOnly)|Provides read-only access to Amazon EC2 Container Registry repositories.|AWS|
|<a name="AmazonSSMManagedInstanceCore"></a>[AmazonSSMManagedInstanceCore](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/AmazonSSMManagedInstanceCore)|The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality.|AWS|
|<a name="&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-ingress-nginx-sa-policy"></a>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-eks-ingress-nginx-sa-policy](./)|A generic AWS IAM policy for the ingress nginx irsa.|Customer|
|<a name="&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-s3-policy"></a>[&lt;tenant&gt;-&lt;environment&gt;-&lt;zone&gt;-s3-policy](./modules/simphera_aws_instance/templates/minio-policy.json)|Allows access to S3 bucket.|Customer|