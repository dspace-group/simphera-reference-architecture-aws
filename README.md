# SIMPHERA Reference Architecture for AWS

This repository contains the reference architecture of the infrastructure needed to deploy dSPACE SIMPHERA to AWS. It does not contain the helm chart needed to deploy SIMPHERA itself, but only the base infrastructure such as Kubernetes, PostgreSQL, storage accounts, etc.

You can use the reference architecture as a starting point for your SIMPHERA installation if you plan to deploy SIMPHERA to AWS. You can use the reference architecture as it is and only have to configure few individual values. If you have special requirements feel free to adapt the architecture to your needs. For example, the reference architecture does not contain any kind of VPN connection to a private, on-premise network because this is highly user specific. But the reference architecture is configured in such a way that the ingress points are available in the public internet.

Using the reference architecture you can deploy a single or even multiple instances of SIMPHERA, e.g. one for _production_ and one for _testing_.

## Architecture

The following figure shows the main resources of the architecture:
![SIMPHERA Reference Architecture for AWS](AWSReferenceArchitecture.png)
The main building brick of the SIMPHERA reference architecture for AWS is the Amazon EKS cluster.
The cluster contains two auto scaling groups:
The first group is reserved for SIMPHERA services and other auxiliary third-party services like Keycloak, nginx, etc.
The second group is for the executors that perform the testing of the system under test.
The data for SIMPHERA projects is stored in a Amazon RDS PostgreSQL instance.
Keycloak stores SIMPHERA users in a separate Amazon RDS PostgreSQL instance.
Executors need licenses to execute tests and simulations.
They obtain the licenses from a license server.
The license server is deployed on a EC2 instance.
Project files and test results are stored in an non-public Amazon S3 bucket.
For the initial setup of the license server, several files need to be exchanged between an administration PC and the license server.
These files are exchanged via an non-public S3 bucket that can be read and written from the administration PC and the license server.
A detailed list of the AWS resources that are mandatory/optional for the operation of SIMPHERA can be found in the [AWSCloudSpec](./AWSCloudSpec.md).

## Usage Instructions

To create the AWS resources that are required for operating SIMPHERA, you need to accomplish the following tasks:
1. install Terraform on your local administration PC
1. register an AWS account where the resources needed for SIMPHERA are created
1. create IAM user with least privileges required to create the resources for SIMPHERA
1. create security credentials for that IAM user
1. create non-public S3 bucket for Terraform state
1. create IAM policy that gives the IAM user access to the S3 bucket
1. clone this repository onto your local administration PC
1. adjust Terraform variables
1. apply Terraform configuration
1. connect to the Kubernetes cluster

### Install Terraform
This reference architecture is provided as a [Terraform](https://terraform.io/) configuration. Terraform is an open-source command line tool to automatically create and manage cloud resources. A Terraform configuration consists of various `.tf` text files. These files contain the specifications of the resources to be created in the cloud infrastructure. That is the reason why this approach is called _infrastructure-as-code_. The main advantage of this approach is _reproducibility_ becaue the configuration can be mainted in a source control system such as Git.

Terraform uses _variables_ to make the specification configurable. The concrete values for these variables are specified in `.tfvars` files. So it is the task of the administrator to fill the `.tfvars` files with the correct values. This is explained in more detail in a later chapter.

Terraform has the concept of a _state_. On the one hand side there are the resource specifications in the `.tf` files. On the other hand there are the resources in the cloud infrastructure that are created based on these files. Terraform needs to store _mapping information_ which element of the specification belongs to which resource in the cloud infrastructure. This mapping is called the _state_. In general you could store the state on your local hard drive. But that is not a good idea because in that case nobody else could change some settings and apply these changes. Therefore the state itself should be stored in the cloud.

This reference architecture has been tested with Terraform version v1.1.7.

### Create Security Credentials

You can create [security credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) for that IAM user with the AWS console.
Terraform uses these security credentials to create AWS resources on your behalf.

On your administration PC you need to install the [Terraform](https://terraform.io/) command and the [AWS CLI](https://aws.amazon.com/cli/).
To [configure your aws account](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) run the following command:
```bash
aws configure

AWS Access Key ID [None]: *********
AWS Secret Access Key [None]: *******
Default region name [None]: eu-central-1
Default output format [None]: json
```

### Create State Bucket

As mentioned before Terraform stores the state of the resources it creates within an S3 bucket. 
The bucket name needs to be globally unique.

After you have created the bucket, you need to link it with Terraform:
To do so, please make a copy of the file `state-backend-template`, name it `state-backend.tf` and open the file in a text editor. The values have to point to an existing storage account to be used to store the Terraform state:

```hcl
terraform {
  backend "s3" {
    #The name of the bucket to be used to store the terraform state. You need to create this container manually.
    bucket = "terraform-state"

    #The name of the file to be used inside the container to be used for this terraform state.
    key    = "simphera.tfstate"
    
    #The region of the bucket.
    region = var.region
  }
}
```
Important: It is highly recommended to enable server-side encryption of the state file. Encryption is not enabled per default.
### Create IAM Policy for State Bucket
Create the following [IAM policy for accessing the Terraform state bucket](https://www.terraform.io/language/settings/backends/s3#s3-bucket-permissions) and assign it to the IAM user:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::terraform-state"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::terraform-state/simphera.tfstate"
        }
    ]
}
```
### Adjust Terraform Variables

For your configuration, please make a copy of the file `terraform.tfvars.example`, name it `terraform.tfvars` and open the file in a text editor. This file contains all variables that are configurable including documentation of the variables. Please adapt the values before you deploy the resources.
Secrets and passwords should not be stored as plain text in the tfvars file. 
Important: It is highly recommended to store the passwords in AWS Secrets Manager and to read them with a [`aws_secretsmanager_secret_version`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) data source.

### Apply Terraform Configuration

Before you can deploy the resources to AWS you have to initialize Terraform:

```sh
terraform init
```

Afterwards you can deploy the resources:

```sh
terraform apply
```
Terraform automatically loads the variables from your `terraform.tfvars` variable definition file.

To delete all resources from your AWS account you have to execute the following command:

```sh
terraform destroy
```

### Connect to Kubernetes Cluster

This deployment contains a managed Kubernetes cluster (EKS). In order to use command line tools such as `kubectl` or `helm` you need a _kubeconfig_ configuration file. This file will automatically be exported by Terraform under the filename `kubeconfig_<tenant>-<environment>-<zone>`.

Alternatively, you can get the cluster credentials by using the following command:

```bash
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

## Backups

SIMPHERA stores data in the PostgreSQL database and in S3 buckets (MinIO).
It is recommended to enable continuous backups which allows point-in-time recovery.
[Point-in-time recovery](https://docs.aws.amazon.com/aws-backup/latest/devguide/point-in-time-recovery.html) lets you restore your data to any point in time within a defined retention period.
Versioning must be enabled on S3 buckets which is a requirement for point-in-time recovery.
These Terraform files enable versioning for the S3 bucket that is used for MinIO.
The AWS documentation describes how to [restore a database](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-rds.html) and how to [restore S3 data](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-s3.html).
It is recommended to copy the backups of a production resource deployed in one AWS region to another AWS region.
In case of a disaster in the region of a production resource its backup can still be restored.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.74.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | git::https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git | v3.3.0 |
| <a name="module_eks-addons"></a> [eks-addons](#module\_eks-addons) | git::https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git//modules/kubernetes-addons | v3.3.0 |
| <a name="module_simphera_instance"></a> [simphera\_instance](#module\_simphera\_instance) | ./modules/simphera_aws_instance | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | v3.11.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.license_server_profile](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.license_server_role](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.role_policy](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/iam_role_policy) | resource |
| [aws_instance.license_server](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/instance) | resource |
| [aws_s3_bucket.license_server_bucket](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/resources/s3_bucket) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/3.74.3/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account id to be used to create resources. | `string` | n/a | yes |
| <a name="input_dspaceEulaAccepted"></a> [dspaceEulaAccepted](#input\_dspaceEulaAccepted) | By setting this variable to true you accept the dSPACE End User License Agreement (https://www.dspace.com/en/pub/home/support/eula.cfm). | `string` | n/a | yes |
| <a name="input_enable_aws_for_fluentbit"></a> [enable\_aws\_for\_fluentbit](#input\_enable\_aws\_for\_fluentbit) | Install FluentBit to send container logs to CloudWatch. | `bool` | `false` | no |
| <a name="input_enable_aws_open_telemetry"></a> [enable\_aws\_open\_telemetry](#input\_enable\_aws\_open\_telemetry) | Install AWS Distro for OpenTelemetry to collect cluster metrics and send them to AWS CloudWatch. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_kubernetesVersion"></a> [kubernetesVersion](#input\_kubernetesVersion) | The version of the AKS cluster. | `string` | `"1.21"` | no |
| <a name="input_licenseServer"></a> [licenseServer](#input\_licenseServer) | Specifies whether a license server VM will be created. | `bool` | `false` | no |
| <a name="input_linuxExecutionNodeCountMax"></a> [linuxExecutionNodeCountMax](#input\_linuxExecutionNodeCountMax) | The maximum number of Linux nodes for the job execution | `number` | `10` | no |
| <a name="input_linuxExecutionNodeCountMin"></a> [linuxExecutionNodeCountMin](#input\_linuxExecutionNodeCountMin) | The minimum number of Linux nodes for the job execution | `number` | `0` | no |
| <a name="input_linuxExecutionNodeSize"></a> [linuxExecutionNodeSize](#input\_linuxExecutionNodeSize) | The machine size of the Linux nodes for the job execution | `string` | `"t3.medium"` | no |
| <a name="input_linuxNodeCountMax"></a> [linuxNodeCountMax](#input\_linuxNodeCountMax) | The maximum number of Linux nodes for the regular services | `number` | `12` | no |
| <a name="input_linuxNodeCountMin"></a> [linuxNodeCountMin](#input\_linuxNodeCountMin) | The minimum number of Linux nodes for the regular services | `number` | `1` | no |
| <a name="input_linuxNodeSize"></a> [linuxNodeSize](#input\_linuxNodeSize) | The machine size of the Linux nodes for the regular services | `string` | `"m5a.4xlarge"` | no |
| <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts) | Additional AWS account numbers to add to the aws-auth ConfigMap | `list(string)` | `[]` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_microsoftDotnetLibraryLicenseAccepted"></a> [microsoftDotnetLibraryLicenseAccepted](#input\_microsoftDotnetLibraryLicenseAccepted) | By setting this variable to true you accept the Microsoft .NET Library License (https://www.microsoft.com/web/webpi/eula/net_library_eula_enu.htm). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to be used. | `string` | `"eu-central-1"` | no |
| <a name="input_simpheraInstances"></a> [simpheraInstances](#input\_simpheraInstances) | A list containing the individual SIMPHERA instances, such as 'staging' and 'production'. | <pre>map(object({<br>    name                         = string<br>    postgresqlAdminLogin         = string<br>    postgresqlAdminPassword      = string<br>    postgresqlVersion            = string<br>    postgresqlStorage            = number<br>    db_instance_type_simphera    = string<br>    db_instance_type_keycloak    = string<br>    k8s_namespace                = string<br>    secret_minio_accesskey       = string<br>    secret_minio_secretkey       = string<br>    secret_couchdb_adminPassword = string<br>    secret_couchdb_adminUsername = string<br>    secret_keycloak_password     = string<br>    secret_tls_public_file       = string<br>    secret_tls_private_file      = string<br>    simphera_fqdn                = string<br>    keycloak_fqdn                = string<br>    minio_fqdn                   = string<br>    license_server_fqdn          = string<br>    simphera_chart_registry      = optional(string)<br>    simphera_chart_repository    = optional(string)<br>    simphera_chart_tag           = optional(string)<br>    simphera_image_tag           = optional(string)<br>    registry_username            = optional(string)<br>    registry_password            = optional(string)<br>    simphera_chart_local_path    = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to be added to all resources. | `map(any)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account name or unique account id e.g., apps or management or aws007 | `string` | `"aws"` | no |
| <a name="input_vpcCidr"></a> [vpcCidr](#input\_vpcCidr) | The CIDR for the virtual private cluster. | `string` | `"10.1.0.0/18"` | no |
| <a name="input_vpcDatabaseSubnets"></a> [vpcDatabaseSubnets](#input\_vpcDatabaseSubnets) | List of CIDRs for the database subnets. | `list(any)` | <pre>[<br>  "10.1.24.0/22",<br>  "10.1.28.0/22",<br>  "10.1.32.0/22"<br>]</pre> | no |
| <a name="input_vpcPrivateSubnets"></a> [vpcPrivateSubnets](#input\_vpcPrivateSubnets) | List of CIDRs for the private subnets. | `list(any)` | <pre>[<br>  "10.1.0.0/22",<br>  "10.1.4.0/22",<br>  "10.1.8.0/22"<br>]</pre> | no |
| <a name="input_vpcPublicSubnets"></a> [vpcPublicSubnets](#input\_vpcPublicSubnets) | List of CIDRs for the public subnets. | `list(any)` | <pre>[<br>  "10.1.12.0/22",<br>  "10.1.16.0/22",<br>  "10.1.20.0/22"<br>]</pre> | no |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `"dev"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->