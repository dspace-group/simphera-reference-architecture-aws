# dSPACE Cloud Products Reference Architecture for AWS

dSPACE offers a variety of cloud-deployable products. These products require the same basic infrastructure resources, such as VPC, Kubernetes, and S3 buckets. Additionally, for various products, specific cloud infrastructure resources may be required. This repository is used for deployment of such products to the AWS cloud provider via Terraform.

Helm charts needed for deployment of dSPACE products are not contained in this repository.

You can use the reference architecture as a starting point for your installation of dSPACE Cloud Products to AWS. You can use the reference architecture as it is and only have to configure few individual values. If you have special requirements feel free to adapt the architecture to your needs. For example, the reference architecture does not contain any kind of VPN connection to a private, on-premise network because this is highly user specific. But the reference architecture is configured in such a way that the ingress points are available in the public internet.

Using the reference architecture you can deploy a single or even multiple instances of SIMPHERA/IVS, e.g. one for _production_ and one for _testing_.

## Architecture

The following figure shows the main resources of the architecture:
![Cloud Products Reference Architecture for AWS](AWSReferenceArchitecture.svg)

The following figure shows the main resources used for SIMPHERA product:
![SIMPHERA Reference Architecture for AWS](AWSSimpheraReferenceArchitecture.svg)

The following figure shows the main resources used for IVS product:
![IVS Reference Architecture for AWS](AWSIVSReferenceArchitecture.svg)

The main building block of the dSPACE Cloud Products reference architecture for AWS is the Amazon EKS cluster.
The cluster contains auto scaling groups:

| Node Group Description | Taints | Labels |
| ---------------------- | ------ | ------ |
| group reserved for SIMPHERA/IVS services and other auxiliary third-party services like Keycloak, nginx, etc. |  | <ul><li>`kubernetes.io/os: linux`</li></ul> |
| group for the executors that perform the testing of the system under test or for jobs scheduled by IVS.| <ul><li>`purpose: execution; effect: NoSchedule`</li></ul> | <ul><li>`kubernetes.io/os: linux`</li><li>`purpose: execution`</li> <li>`product: ivs`</li></ul> |
| group used for the execution of the tests or simlations that require GPU. It is possible to have different GPU group of this kind for each required NVIDIA driver. | <ul><li>`purpose: gpu; effect: NoSchedule`</li></ul> | <ul><li>`kubernetes.io/os: linux`</li><li>`purpose: gpu`</li><li>`gpu-driver: '__DRIVER_VERSION__'`</li></ul> |
| group used by IVS jobs that require GPU for the execution. | <ul><li>`nvidia.com/gpu; effect: NoSchedule`</li></ul> | <ul><li>`kubernetes.io/os: linux`</li><li>`product: ivs`</li><li>`gpu-driver: '__DRIVER_VERSION__'`</li></ul> |
| group used by IVS jobs that require Windows operating system for the execution. | <ul><li>`purpose:execution; effect: NoSchedule`</li></ul> | <ul><li>`kubernetes.io/os: windows`</li><li>`product: ivs`</li></ul> |

The data for SIMPHERA projects is stored in a Amazon RDS PostgreSQL instance.
Keycloak stores SIMPHERA users in a separate Amazon RDS PostgreSQL instance.
If your IVS installation has Similarity Search feature enabled, embedding tags can be stored in Amazon OpenSearch Service domain.
Executors need licenses to execute tests and simulations.
IVS jobs need licenses to execute imports/processing/tagging of the IVS recordings.
They obtain the licenses from a license server.
The license server is deployed on an EC2 instance.
SIMPHERA project files and test results are stored in an non-public Amazon S3 bucket.
IVS recordings, test results and some static web files are stored in non public Amazon S3 buckets, referenced as `dataBucketName` and `rawDataBucketName`.
For the initial setup of the license server, several files need to be exchanged between an administration PC and the license server.
These files are exchanged via an non-public S3 bucket that can be read and written from the administration PC and the license server.
A detailed list of the AWS resources that are mandatory/optional for the operation of dSPACE Cloud products can be found in the [AWSCloudSpec](./AWSCloudSpec.md).

## Billable Resources and Services

Charges may apply for the following AWS resources and services:

| Service | Description | Product | Mandatory? |
| ------- | ----------- | ------- | ---------- |
| Amazon Elastic Kubernetes Service | A Kubernetes cluster required to run dSPACE Cloud Products. | SIMPHERA/IVS | Yes |
| Amazon Virtual Private Cloud | Virtual network for dSPACE Cloud Products. | SIMPHERA/IVS | Yes |
| Elastic Load Balancing | A network load balancer used to access deployed services. | SIMPHERA/IVS | Yes |
| Amazon EC2 Auto Scaling | Automatically scales compute nodes if the capacity is exhausted. | SIMPHERA/IVS | Yes |
| Amazon Relational Database | Project and authorization data is stored in Amazon RDS for PostgreSQL instances. | SIMPHERA | Yes |
| Amazon Simple Storage Service | Binary artifacts and static data are stored in an S3 bucket. | SIMPHERA/IVS | Yes |
| Amazon Elastic File System | Binary artifacts are stored temporarily in EFS. | SIMPHERA | Yes |
| AWS Key Management Service (AWS KMS) | Encryption for Kubernetes secrets is enabled by default. | SIMPHERA/IVS | Yes |
| Amazon Elastic Compute Cloud | Optionally, you can deploy a dSPACE license server on an EC2 instance. Alternatively, you can deploy the server on external infrastructure. For additional information, please contact our support team. | SIMPHERA/IVS | Yes |
| Amazon CloudWatch | Metrics and container logs to CloudWatch. It is recommended to deploy the dSPACE monitoring stack in Kubernetes.| SIMPHERA/IVS ||
| Amazon OpenSearch Service | Database service for storing embedding tags, used by IVS embedding service and Similarity search feature | IVS ||
| Amazon Elastic Block Store | Block storage volumes used for EC2 volumes or as persistent volumes in Kubernetes cluster | SIMPHERA/IVS | Yes (IVS) |

## Usage Instructions

To create the AWS resources that are required for operating the dSPACE Cloud Products from your local administration PC, you need to accomplish the following tasks:

1. install Terraform on your local administration PC
1. register an AWS account where the resources needed for dSPACE Cloud Products are created
1. create an IAM user with least privileges required to create the resources for dSPACE Cloud Products
  - to deploy all products use [deploy_all_policy.json](./templates/least_permissions/deploy_all_policy.json)
  - for SIMPHERA deployment use [deploy_simphera_policy.json](./templates/least_permissions/deploy_simphera_policy.json)
  - for IVS deployment use [deploy_ivs_policy.json](./templates/least_permissions/deploy_ivs_policy.json)
1. create security credentials for that IAM user
1. request service quota increase for gpu instances if needed
1. create non-public S3 bucket for Terraform state
1. create IAM policy that gives the IAM user access to the S3 bucket
1. clone this repository onto your local administration PC
1. create Secrets manager secrets
1. adjust Terraform variables to match your usage (SIMPHERA/IVS/all)
1. apply Terraform configuration
1. connect to the Kubernetes cluster

### Install Terraform

This reference architecture is provided as a [Terraform](https://terraform.io/) configuration. Terraform is an open-source command line tool to automatically create and manage cloud resources. A Terraform configuration consists of various `.tf` text files. These files contain the specifications of the resources to be created in the cloud infrastructure. That is the reason why this approach is called _infrastructure-as-code_. The main advantage of this approach is _reproducibility_ because the configuration can be mainted in a source control system such as Git.

Terraform uses _variables_ to make the specification configurable. The concrete values for these variables are specified in `.tfvars` files. So it is the task of the administrator to fill the `.tfvars` files with the correct values. This is explained in more detail in a later chapter.

Terraform has the concept of a _state_. On the one hand side there are the resource specifications in the `.tf` files. On the other hand there are the resources in the cloud infrastructure that are created based on these files. Terraform needs to store _mapping information_ which element of the specification belongs to which resource in the cloud infrastructure. This mapping is called the _state_. In general you could store the state on your local hard drive. But that is not a good idea because in that case nobody else could change some settings and apply these changes. Therefore the state itself should be stored in the cloud.

### Request service quota for gpu computing instances

If you want to run [AURELION](https://www.dspace.com/en/pub/home/products/sw/experimentandvisualization/aurelion_sensor-realistic_sim.cfm) with your SIMPHERA solution or any other workload that requires gpus such as annotation tasks in IVS, you need to add gpu instances to your cluster.

In case you want to add a gpu node pool to your AWS infrastructure, you might have to increase the [quota](https://docs.aws.amazon.com/servicequotas/latest/userguide/intro.html) for the gpu instance type you have selected. Per default, the Cloud Products Reference Architecture for AWS uses g5.2xlarge instances. The quota [_Running On-Demand P instances_](https://console.aws.amazon.com/servicequotas/home/services/ec2/quotas/L-417A185B) sets the maximum number of vCPUs assigned to the Running On-Demand P instances for a specific AWS region. Every g5.2xlarge instance has 8 vCPUs, which is why the quota has to be at least 8 for the AWS region where you want to deploy the instances.

### Create Security Credentials <a name="awsprofile"></a>

You can create [security credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) for that IAM user with the AWS console.
Terraform uses these security credentials to create AWS resources on your behalf.

On your administration PC you need to install the [Terraform](https://terraform.io/) command and the [AWS CLI](https://aws.amazon.com/cli/).
To [configure your aws account](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) run the following command:

```bash
aws configure --profile <profile-name>

AWS Access Key ID [None]: *********
AWS Secret Access Key [None]: *******
Default region name [None]: eu-central-1
Default output format [None]: json
```

If you have been provided with session token, you can add it via following command:

```bash
aws configure set aws_session_token "<your_session_token>" --profile <profile-name>
```

Access credentials are typically stored in `~/.aws/credentials` and configurations in `~/.aws/config`.
There are [various ways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) on how to authenticate, to run Terraform.
This depends on your specific setup.

Verify connectivity and your access credentials by executing following command:

```bash
aws sts get-caller-identity

{
    "UserId": "REWAYDCFMNYCPKCWRZEHT:JohnDoe@dspace.com",
    "Account": "592245445799",
    "Arn": "arn:aws:sts::592245445799:assumed-role/AWSReservedSSO_AdministratorAccess_vmcbaym7ueknr9on/JohnDoe@dspace.com"
}
```

### Create State Bucket

As mentioned before, Terraform stores the state of the resources it creates within an S3 bucket.
The bucket name needs to be globally unique.

After you have created the bucket, you need to link it with Terraform:
To do so, please make a copy of the file `state-backend-template`, name it `state-backend.tf` and open the file in a text editor. With this backend configuration, Terraform stores the state as a given `key` in the given S3 `bucket` you have created before.


```hcl
terraform {
  backend "s3" {
    #The name of the bucket to be used to store the terraform state. You need to create this container manually.
    bucket = "terraform-state"
    #The name of the file to be used inside the container to be used for this terraform state.
    key    = "simphera.tfstate"
    #The region of the bucket.
    region = "eu-central-1"
  }
}
```

Important: It is highly recommended to [enable server-side encryption of the state file](https://www.terraform.io/language/settings/backends/s3). Encryption is not enabled per default.

### Create IAM Policy for State Bucket

Create the following [IAM policy for accessing the Terraform state bucket](https://www.terraform.io/language/settings/backends/s3#s3-bucket-permissions) and assign it to the IAM user:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "<your_account_arn>"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::terraform-state"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "<your_account_arn>"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::terraform-state/<storage_key_state_backend>"
        }
    ]
}
```

Your account ARN (Amazon Resource Number) is in the output of `aws sts get-caller-identity` command.

### Create Secrets Manager Secrets

You have to provide the name of the certain secrets in your Terraform variables.
To create required secrets, follow these instructions.

#### PostgreSQL (SIMPHERA)
Username and password for the PostgreSQL databases are stored in AWS Secrets Manager.
Before you let Terraform create AWS resources, you need to manually create a Secrets Manager secret that stores the username and password.
It is recommended to create individual secrets per SIMPHERA instance (e.g. production and staging instance).
To create the secret, open the Secrets Manager console and click the button `Store a new secret`.
As secret type choose `Other type of secret`.
The password must contain from 8 to 128 characters and must not contain any of the following: / (slash), '(single quote), "(double quote) and @ (at sign).
Open the Plaintext tab and paste the following JSON object and enter your usernames and passwords:

```json
{
  "postgresql_password": "<your password>"
}
```

Alternatively, you can create the secret with the following Powershell script:

```powershell
$region = "<your region>"
$postgresqlCredentials = @"
{
    "postgresql_password" : "<your password>"
}
"@ | ConvertFrom-Json | ConvertTo-Json -Compress
$postgresqlCredentials = $postgresqlCredentials -replace '([\\]*)"', '$1$1\"'
aws secretsmanager create-secret --name <secret name> --secret-string $postgresqlCredentials --region $region
```

On the next page you can define a name for the secret.
Automatic credentials rotation is currently not supported by SIMPHERA, but you can <a href="#rotating-credentials">rotate secrets manually</a>.

#### OpenSearch (IVS)
Master username and master password for the OpenSearch databases are stored in AWS Secrets Manager.
Before you let Terraform create AWS resources, you need to manually create a Secrets Manager secret that stores the username and password.
It is recommended to create individual secrets per IVS instance (e.g. production and staging instance).
To create the secret, open the Secrets Manager console and click the button `Store a new secret`.
As secret type choose `Other type of secret`.
The password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character..
Open the Plaintext tab and paste the following JSON object and enter your usernames and passwords:

```json
{
  "master_user": "your_username",
  "master_password": "your_password"
}
```

### Adjust Terraform Variables

For your configuration, please rename the template file `terraform.tfvars.example` to `terraform.tfvars` and open it in a text editor.
This file contains all variables that are configurable including documentation of the variables. Please adapt the values before you deploy the resources.

For example, adapt name of the secret used for PostgreSQL, related to the SIMPHERA product:
```diff
simpheraInstances = {
  "production" = {
+    secretname = "<secret name>"
    }
}
```

Also rename the file `providers.tf.example` to `main.tf` and fill in the name of the [AWS profile you have created before](#awsprofile).

```diff
provider "aws" {
+  profile = "<profile-name>"
}
```

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
Installation times may very, but it is expected to take up to 30 min to complete the deployment.
Note that `eks-addons` module dependency on managed node group(s) is commented out in `k8s.tf` file. This might increase
deployment time, as various addons might be provisioned before any actual K8s worker node starts, to complete addon deployment.
Default timeout for node/addon deployment is 20 minutes, so please be patient.  If this behaviour creates problems, you can
always uncomment line `depends_on = [module.eks.node_groups]`.
It is recommended to use AWS `admin` account, or ask your AWS administrator to assign necessary IAM roles and permissions to your user.

### Destroy Infrastructure

Resources that contain data, i.e. the databases, S3 storage, and the recovery points in the backup vault are protected against unintentional deletion.
> [!WARNING]
> **If you continue with the procedure described in this section, your data will be irretrievably deleted**.

#### Backup vaults

Before the backup vault can be deleted, all the continuous recovery points for S3 storage and the databases need to be deleted, for example by using the following Powershell snippet:

```powershell
$vaults = terraform output backup_vaults | ConvertFrom-Json
$profile = "<profile_name>"
foreach ($vault in $vaults){
  Write-Host "Deleting $vault"
  $recoverypoints = aws backup list-recovery-points-by-backup-vault --profile $profile --backup-vault-name $vault | ConvertFrom-Json
  foreach ($rp in $recoverypoints.RecoveryPoints){
    aws backup delete-recovery-point --profile $profile --backup-vault-name $vault --recovery-point-arn $rp.RecoveryPointArn
  }
  foreach ($rp in $recoverypoints.RecoveryPoints){
    Do
    {
      Start-Sleep -Seconds 10
      aws backup describe-recovery-point --profile $profile --backup-vault-name $vault --recovery-point-arn $rp.RecoveryPointArn | ConvertFrom-Json
    } while( $LASTEXITCODE -eq 0)
  }
  aws backup delete-backup-vault --profile $profile --backup-vault-name $vault
}
```

#### RDS databases (SIMPHERA)

Before the databases can be deleted, you need to remove their delete protection:

```powershell
$databases = terraform output database_identifiers | ConvertFrom-Json
foreach ($db in $databases){
  Write-Host "Deleting database $db"
  aws rds modify-db-instance --profile $profile --db-instance-identifier $db --no-deletion-protection
  aws rds delete-db-instance --profile $profile --db-instance-identifier $db --skip-final-snapshot
}
```

#### S3 buckets

To delete the S3 buckets that contains both versioned and non-versioned objects, the buckets must first be emptied. The following PowerShell script can be used to erase all objects within the buckets and then delete the buckets.

```powershell
$aws_profile = "<profile_name>"
$buckets = terraform output s3_buckets | ConvertFrom-Json
foreach ($bucket in $buckets) {
    Write-Output "Deleting bucket: $bucket" 
    $deleteObjDict = @{}
    $deleteObj = New-Object System.Collections.ArrayList
    aws s3api list-object-versions --bucket $bucket --profile $aws_profile --query '[Versions[*].{ Key:Key , VersionId:VersionId} , DeleteMarkers[*].{ Key:Key , VersionId:VersionId}]' --output json `
    | ConvertFrom-Json | ForEach-Object { $_ } | ForEach-Object { $deleteObj.add($_) } | Out-Null
    $n = [math]::Ceiling($deleteObj.Count / 100)
    for ($i = 0; $i -lt $n; $i++) {
        $deleteObjDict["Objects"] = $deleteObj[(0 + $i * 100)..(100 * ($i + 1))]
        $deleteObjDict["Objects"] = $deleteObjDict["Objects"] | Where-Object { $_ -ne $null }
        $deleteStuff = $deleteObjDict | ConvertTo-Json
        aws s3api delete-objects --bucket $bucket --profile $aws_profile --delete $deleteStuff | Out-Null
    }
    aws s3 rb s3://$bucket --force --profile $aws_profile
    Write-Output "$bucket bucket deleted"
}
```

The remaining infrastructure resources can be deleted via Terraform by running the following command.

```sh
terraform destroy
```

### Connect to Kubernetes Cluster

This deployment contains a managed Kubernetes cluster (EKS).
In order to use command line tools such as `kubectl` or `helm` you need a _kubeconfig_ configuration file.
You can update your _kubeconfig_ using the [aws cli update-kubeconfig command](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/eks/update-kubeconfig.html):

```bash
aws eks --region <region> update-kubeconfig --name <cluster_name> --kubeconfig <filename>
```

## Backup and Restore (SIMPHERA)

SIMPHERA stores data in the PostgreSQL database and in S3 buckets (MinIO) that needs to be backed up.
AWS supports continuous backups for Amazon RDS for PostgreSQL and S3 that allows point-in-time recovery.
[Point-in-time recovery](https://docs.aws.amazon.com/aws-backup/latest/devguide/point-in-time-recovery.html) lets you restore your data to any point in time within a defined retention period.

This Terraform module creates an AWS backup plan that makes continuous backups of the PostgreSQL database and S3 buckets.
The backups are stored in an AWS backup vault per SIMPHERA instance.
An IAM role is also automatically created that has proper permissions to create backups.
To enable backups for your SIMPHERA instance, make sure you have the flag `enable_backup_service` et in your `.tfvars` file:

```hcl
simpheraInstances = {
  "production" = {
        enable_backup_service    = true
    }
}
```

### Amazon RDS for PostgreSQL (SIMPHERA)

Create an target RDS instance (backup server) that is a copy of a source RDS instance (production server) of a specific point-in-time.
The command [`restore-db-instance-to-point-in-time`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/rds/restore-db-instance-to-point-in-time.html) creates the target database.
Most of the configuration settings are copied from the source database.
To be able to connect to the target instance the easiest way is to explicitly set the same security group and subnet group as used for the source instance.

Restoring an RDS instance can be done via Powershell as described in the remainder:

```bash
aws rds restore-db-instance-to-point-in-time --source-db-instance-identifier simphera-reference-production-simphera --target-db-instance simphera-reference-production-simphera-backup --vpc-security-group-ids sg-0b954a0e25cd11b6d --db-subnet-group-name simphera-reference-vpc --restore-time 2022-06-16T23:45:00.000Z --tags Key=timestamp,Value=2022-06-16T23:45:00.000Z
```

Execute the following command to create the pgdump pod using the standard postgres image and open a bash:

```bash
kubectl run pgdump -ti -n simphera --image postgres --kubeconfig .\kube.config -- bash
```

In the pod's Bash, use the pg_dump and pg_restore commands to stream the data from the backup server to the production server:

```bash
pg_dump -h simphera-reference-production-simphera-backup.cexy8brfkmxk.eu-central-1.rds.amazonaws.com -p 5432 -U dbuser -Fc simpherareferenceproductionsimphera | pg_restore --clean --if-exists -h simphera-reference-production-simphera.cexy8brfkmxk.eu-central-1.rds.amazonaws.com -p 5432 -U dbuser -d simpherareferenceproductionsimphera
```

Alternatively, you can [restore the RDS instance via the AWS console](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-rds.html).

### S3

This Terraform creates an S3 bucket for project data and results and enables versioning of the S3 bucket which is a requirement for point-in-time recovery.

To restore the S3 buckets to an older version you need to create an IAM role that has proper permissions:

```powershell
$rolename = "restore-role"
$trustrelation = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
"@
echo $trustrelation > trust.json
aws iam create-role --role-name $rolename --assume-role-policy-document file://trust.json --description "Role to restore"
aws iam attach-role-policy --role-name $rolename --policy-arn="arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
aws iam attach-role-policy --role-name $rolename --policy-arn="arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
$rolearn=aws iam get-role --role-name $rolename --query 'Role.Arn'
```

Restoring an S3 bucket can be done via Powershell as described in the remainder:
You can restore the S3 data in-place, into another existing bucket, or into a new bucket.

```powershell
$uuid = New-Guid
$metadata = @"
{
  "DestinationBucketName": "DESTINATION_BUCKET_NAME",
  "NewBucket": "true",
  "RestoreTime": "2022-06-20T23:45:00.000Z",
  "Encrypted": "false",
  "CreationToken": "$uuid"
}
"@
$metadata = $metadata -replace '([\\]*)"', '$1$1\"'
aws backup start-restore-job `
--recovery-point-arn "arn:aws:backup:eu-central-1:012345678901:recovery-point:continuous:simphera-reference-production-0f51c39b" `
--iam-role-arn $rolearn `
--metadata $metadata
```

Alternatively, you can [restore the S3 data via the AWS console](https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-s3.html).

## Backup and Restore (IVS)

When IVS instance is deployed with backup enabled user can restore data from one of the backups, MongoDB EBS volume, S3 buckets or OpenSearch Indices.
To enable backups for your IVS instance, make sure you have the flag `backup_service_enable` et in your `.tfvars` file:

```hcl
ivsInstances = {
  "production" = {
        backup_service_enable    = true
    }
}
```

### Restore MongoDB EBS volume

To backup MongoDB EBS volume, user can use [restore_mongodb.ps1](scripts/restore_mongodb.ps1) script.
First find a EBS snapshot arn in IVS backup vault (terraform output backup_vaults) at AWS GUI.

Then just run aforementioned script in powershell console, example:
```
./restore_mongodb.ps1 -clusterid "aws-preprod-dev-eks" -snapshot_arn "arn:aws:ec2:eu-central-1::snapshot/snap-0123456789a" -rolearn "arn:aws:iam::012345678901:role/restorerole" -profile "profile-1" -region "eu-central-1" -kubeconfig "C:\Users\user1\.kube\clusterid\config" -ivs_release_name "ivs" -namespace "ivs"
```

### Restore data/raw-data s3 bucket

For restoring backup of data or raw-data S3 buckets refer to [SIMPHERA Administration manual](https://www.dspace.com/en/pub/home/support/kb/supkbspecial/simphdocs/simphadmin.cfm), section `Protecting MinIO Data Using AWS S3` subsection `Restoring data`.

### Restore AWS OpenSearch Service indices

Connect to one of the EKS node shell.
Get list of all available snapshots you want to restore:
```
curl -XGET -u 'USERNAME:PASSWORD' 'https://OPENSEARCH_DOMAIN/_cat/snapshots/cs-automated-enc?v'
```

Run command to close index you wish to restore:
```
curl -XPOST -u 'USERNAME:PASSWORD' 'https://OPENSEARCH_DOMAIN/INDEX_NAME/_close'
```

Run command to restore certain index:
```
curl -XPOST -u 'USERNAME:PASSWORD' 'https://OPENSEARCH_DOMAIN/_snapshot/cs-automated-enc/SNAPSHOT_ID/_restore?wait_for_completion' -H 'Content-Type: application/json' -d'
{
  "indices": "INDEX_NAME"
}
'
```

Run command to open index you restored:
```
curl -XPOST -u 'USERNAME:PASSWORD' 'https://OPENSEARCH_DOMAIN/INDEX_NAME/_open
```


## Encryption

Encryption is enabled at all AWS resources that are created by Terraform:

- EKS/secrets
  - encrypted using Customer managed KMS key created at [kms.tf](.\modules\eks\kms.tf)
- PostgreSQL databases
  - RDS DB instances storage is encrypted by AWS managed KMS key of alias `aws/rds`
- S3 buckets
  - encrypted by Server-side encryption with AWS Key Management Service keys (SSE-KMS), AWS managed KMS of alias `aws/s3` is used
- EFS (Elastic file system)
  - encrypted using AWS managed KMS key of alias `aws/elasticfilesystem`
- EBS volumes attached to EC2 instances
  - encrypted using AWS managed KMS key of alias `aws/ebs`
- CloudWatch logs
  - encrypted using Customer managed KMS key created at [logging.tf](.\logging.tf#L43)
- Backup Vault
  - encrypted using AWS managed KMS key of alias `aws/backup`

## List of tools with versions needed for dSPACE cloud products reference architecture deployment

| Tool name | Version |
| -- | -- |
| AWS CLI | >=2.10.0 |
| Helm | >=3.8.0 |
| Terraform | >=1.9.0 |
| kubectl | >=1.27.0 |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.60.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.13.2 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.19.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.60.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | ./modules/eks | n/a |
| <a name="module_ivs_instance"></a> [ivs\_instance](#module\_ivs\_instance) | ./modules/ivs_aws_instance | n/a |
| <a name="module_k8s_eks_addons"></a> [k8s\_eks\_addons](#module\_k8s\_eks\_addons) | ./modules/k8s_eks_addons | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | ~> 4 |
| <a name="module_security_group_license_server"></a> [security\_group\_license\_server](#module\_security\_group\_license\_server) | terraform-aws-modules/security-group/aws | ~> 4 |
| <a name="module_simphera_instance"></a> [simphera\_instance](#module\_simphera\_instance) | ./modules/simphera_aws_instance | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | v5.8.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flowlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ssm_install_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ssm_scan_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_pull_through_cache_rule.dspacecloudreleases](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_efs_file_system.efs_file_system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_flow_log.flowlog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_instance_profile.license_server_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ecr_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.flowlogs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.license_server_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.flowlogs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.license_server_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks-attach-ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.flowlogs_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.license_server_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.minio_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.license_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_kms_key.kms_key_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.bucket_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.license_server_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.buckets_logs_ssl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.license_server_bucket_ssl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.buckets_logs_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.bucket_logs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_secretsmanager_secret.ecr_pullthroughcache_dspacecloudreleases](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.ecr_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_ssm_maintenance_window.install](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window.scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window_target.install](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_target.scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_target.scan_eks_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_task.install](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_maintenance_window_task.scan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_patch_baseline.production](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_baseline) | resource |
| [aws_ssm_patch_group.patch_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_patch_group) | resource |
| [kubernetes_namespace.monitoring_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_storage_class_v1.efs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [random_string.policy_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.al2gpu_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.amazon_linux_kernel5](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.eks_node_custom_inline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.preconfigured](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_load_balancer_controller_config"></a> [aws\_load\_balancer\_controller\_config](#input\_aws\_load\_balancer\_controller\_config) | Input configuration for load\_balancer\_controller deployed with helm release. By setting key 'enable' to 'true', load\_balancer\_controller release will be deployed. 'helm\_repository' is an URL for the repository of load\_balancer\_controller helm chart, where 'helm\_version' is its respective version of a chart. 'chart\_values' is used for changing default values.yaml of a load\_balancer\_controller chart. | <pre>object({<br>    enable          = optional(bool, false)<br>    helm_repository = optional(string, "https://aws.github.io/eks-charts")<br>    helm_version    = optional(string, "1.4.5")<br>    chart_values = optional(string, <<-YAML<br><br>    YAML<br>    )<br>  })</pre> | <pre>{<br>  "enable": false<br>}</pre> | no |
| <a name="input_cloudwatch_retention"></a> [cloudwatch\_retention](#input\_cloudwatch\_retention) | Global cloudwatch retention period for the EKS, VPC, SSM, and PostgreSQL logs. | `number` | `7` | no |
| <a name="input_cluster_autoscaler_config"></a> [cluster\_autoscaler\_config](#input\_cluster\_autoscaler\_config) | Input configuration for cluster-autoscaler deployed with helm release. By setting key 'enable' to 'true', cluster-autoscaler release will be deployed. 'helm\_repository' is an URL for the repository of cluster-autoscaler helm chart, where 'helm\_version' is its respective version of a chart. 'chart\_values' is used for changing default values.yaml of a cluster-autoscaler chart. | <pre>object({<br>    enable          = optional(bool, true)<br>    helm_repository = optional(string, "https://kubernetes.github.io/autoscaler")<br>    helm_version    = optional(string, "9.37.0")<br>    chart_values = optional(string, <<-YAML<br><br>    YAML<br>    )<br>  })</pre> | `{}` | no |
| <a name="input_codemeter"></a> [codemeter](#input\_codemeter) | Download link for codemeter rpm package. | `string` | `"https://www.wibu.com/support/user/user-software/file/download/13346.html?tx_wibudownloads_downloadlist%5BdirectDownload%5D=directDownload&tx_wibudownloads_downloadlist%5BuseAwsS3%5D=0&cHash=8dba7ab094dec6267346f04fce2a2bcd"` | no |
| <a name="input_coredns_config"></a> [coredns\_config](#input\_coredns\_config) | Input configuration for AWS EKS add-on coredns. By setting key 'enable' to 'true', coredns add-on is deployed. Key 'configuration\_values' is used to change add-on configuration. Its content should follow add-on configuration schema (see https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-advanced-configuration/). | <pre>object({<br>    enable               = optional(bool, true)<br>    configuration_values = optional(string, null)<br>  })</pre> | <pre>{<br>  "enable": true<br>}</pre> | no |
| <a name="input_ecr_pullthrough_cache_rule_config"></a> [ecr\_pullthrough\_cache\_rule\_config](#input\_ecr\_pullthrough\_cache\_rule\_config) | Specifies if ECR pull through cache rule and accompanying resources will be created. Key 'enable' indicates whether pull through cache rule needs to be enabled for the cluster. When 'enable' is set to 'true', key 'exist' indicates whether pull through cache rule already exists for region's private ECR. If key 'enable' is set to 'true', IAM policy will be attached to the cluster's nodes. Additionally, if 'exist' is set to 'false', credentials for upstream registry and pull through cache rule will be created | <pre>object({<br>    enable = bool<br>    exist  = bool<br>  })</pre> | <pre>{<br>  "enable": false,<br>  "exist": false<br>}</pre> | no |
| <a name="input_efs_csi_config"></a> [efs\_csi\_config](#input\_efs\_csi\_config) | Input configuration for AWS EKS add-on efs csi. By setting key 'enable' to 'true', efs csi add-on is deployed. | <pre>object({<br>    enable = optional(bool, true)<br>  })</pre> | <pre>{<br>  "enable": true<br>}</pre> | no |
| <a name="input_enable_patching"></a> [enable\_patching](#input\_enable\_patching) | Scans license server EC2 instance and EKS nodes for updates. Installs patches on license server automatically. EKS nodes need to be updated manually. | `bool` | `false` | no |
| <a name="input_gpuNodeCountMax"></a> [gpuNodeCountMax](#input\_gpuNodeCountMax) | The maximum number of nodes for gpu job execution | `number` | `12` | no |
| <a name="input_gpuNodeCountMin"></a> [gpuNodeCountMin](#input\_gpuNodeCountMin) | The minimum number of nodes for gpu job execution | `number` | `0` | no |
| <a name="input_gpuNodeDiskSize"></a> [gpuNodeDiskSize](#input\_gpuNodeDiskSize) | The disk size in GiB of the nodes for the gpu job execution | `number` | `100` | no |
| <a name="input_gpuNodePool"></a> [gpuNodePool](#input\_gpuNodePool) | Specifies whether an additional node pool for gpu job execution is added to the kubernetes cluster | `bool` | `false` | no |
| <a name="input_gpuNodeSize"></a> [gpuNodeSize](#input\_gpuNodeSize) | The machine size of the nodes for the gpu job execution | `list(string)` | <pre>[<br>  "g5.2xlarge"<br>]</pre> | no |
| <a name="input_gpu_operator_config"></a> [gpu\_operator\_config](#input\_gpu\_operator\_config) | Input configuration for the GPU operator chart deployed with helm release. By setting key 'enable' to 'true', GPU operator will be deployed. 'helm\_repository' is an URL for the repository of the GPU operator helm chart, where 'helm\_version' is its respective version of a chart. 'chart\_values' is used for changing default values.yaml of the GPU operator chart. | <pre>object({<br>    enable          = optional(bool, true)<br>    helm_repository = optional(string, "https://helm.ngc.nvidia.com/nvidia")<br>    helm_version    = optional(string, "v24.9.0")<br>    driver_versions = optional(list(string), ["550.90.07"])<br>    chart_values = optional(string, <<-YAML<br>operator:<br>  defaultRuntime: containerd<br><br>dcgmExporter:<br>  enabled: false<br><br>driver:<br>  enabled: true<br>  nvidiaDriverCRD:<br>    enabled: true<br>    deployDefaultCR: false<br><br>validator:<br>  driver:<br>    env:<br>    - name: DISABLE_DEV_CHAR_SYMLINK_CREATION<br>      value: "true"<br><br>toolkit:<br>  enabled: true<br><br>daemonsets:<br>  tolerations:<br>  - key: purpose<br>    value: gpu<br>    operator: Equal<br>    effect: NoSchedule<br>  - key: nvidia.com/gpu<br>    value: ""<br>    operator: Exists<br>    effect: NoSchedule<br><br>node-feature-discovery:<br>  worker:<br>    tolerations:<br>    - key: purpose<br>      value: gpu<br>      operator: Equal<br>      effect: NoSchedule<br>    - key: nvidia.com/gpu<br>      value: ""<br>      operator: Exists<br>      effect: NoSchedule<br>YAML<br>    )<br>  })</pre> | <pre>{<br>  "enable": false<br>}</pre> | no |
| <a name="input_infrastructurename"></a> [infrastructurename](#input\_infrastructurename) | The name of the infrastructure. e.g. simphera-infra | `string` | `"simphera"` | no |
| <a name="input_ingress_nginx_config"></a> [ingress\_nginx\_config](#input\_ingress\_nginx\_config) | Input configuration for ingress-nginx service deployed with helm release. By setting key 'enable' to 'true', ingress-nginx service will be deployed. 'helm\_repository' is an URL for the repository of ingress-nginx helm chart, where 'helm\_version' is its respective version of a chart. 'chart\_values' is used for changing default values.yaml of an ingress-nginx chart. | <pre>object({<br>    enable          = bool<br>    helm_repository = optional(string, "https://kubernetes.github.io/ingress-nginx")<br>    helm_version    = optional(string, "4.12.1")<br>    chart_values = optional(string, <<-YAML<br>controller:<br>  images:<br>    registry: "registry.k8s.io"<br>  service:<br>    annotations:<br>      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing<br>  allowSnippetAnnotations: true<br>  config:<br>    strict-validate-path-type: false<br>    annotations-risk-level: Critical<br>YAML<br>    )<br>  })</pre> | <pre>{<br>  "enable": false<br>}</pre> | no |
| <a name="input_install_schedule"></a> [install\_schedule](#input\_install\_schedule) | 6-field Cron expression describing the install maintenance schedule. Must not overlap with variable scan\_schedule. | `string` | `"cron(0 3 * * ? *)"` | no |
| <a name="input_ivsGpuDriverVersion"></a> [ivsGpuDriverVersion](#input\_ivsGpuDriverVersion) | Specifies driver version for IVS gpu nodes | `string` | `"550.90.07"` | no |
| <a name="input_ivsGpuNodeCountMax"></a> [ivsGpuNodeCountMax](#input\_ivsGpuNodeCountMax) | The maximum number of GPU nodes nodes for IVS jobs | `number` | `2` | no |
| <a name="input_ivsGpuNodeCountMin"></a> [ivsGpuNodeCountMin](#input\_ivsGpuNodeCountMin) | The minimum number of GPU nodes nodes for IVS jobs | `number` | `0` | no |
| <a name="input_ivsGpuNodeDiskSize"></a> [ivsGpuNodeDiskSize](#input\_ivsGpuNodeDiskSize) | The disk size in GiB of the nodes for the IVS gpu job execution | `number` | `100` | no |
| <a name="input_ivsGpuNodePool"></a> [ivsGpuNodePool](#input\_ivsGpuNodePool) | Specifies whether an additional node pool for IVS gpu job execution is added to the kubernetes cluster | `bool` | `false` | no |
| <a name="input_ivsGpuNodeSize"></a> [ivsGpuNodeSize](#input\_ivsGpuNodeSize) | The machine size of the GPU nodes for IVS jobs | `list(string)` | <pre>[<br>  "g4dn.2xlarge"<br>]</pre> | no |
| <a name="input_ivsInstances"></a> [ivsInstances](#input\_ivsInstances) | A list containing the individual IVS instances, such as 'staging' and 'production'. 'opensearch' object is used for enabling AWS OpenSearch Domain creation.'opensearch.master\_user\_secret\_name' is an AWS secret containing key 'master\_user' and 'master\_password'. 'opensearch.instance\_type' must have option for ebs storage, check available type at https://aws.amazon.com/opensearch-service/pricing/ | <pre>map(object({<br>    k8s_namespace = string<br>    data_bucket = object({<br>      name   = string<br>      create = optional(bool, true)<br>    })<br>    raw_data_bucket = object({<br>      name   = string<br>      create = optional(bool, true)<br>    })<br>    goofys_user_agent_sdk_and_go_version = optional(map(string), { sdk_version = "1.44.37", go_version = "1.17.7" })<br>    opensearch = optional(object({<br>      enable                  = optional(bool, false)<br>      engine_version          = optional(string, "OpenSearch_2.17")<br>      instance_type           = optional(string, "m7g.medium.search")<br>      instance_count          = optional(number, 1)<br>      volume_size             = optional(number, 100)<br>      master_user_secret_name = optional(string, null)<br>      }),<br>      {}<br>    )<br>    ivs_release_name           = optional(string, "ivs")<br>    backup_service_enable      = optional(bool, false)<br>    backup_retention           = optional(number, 7)<br>    backup_schedule            = optional(string, "cron(0 1 * * ? *)")<br>    enable_deletion_protection = optional(bool, true)<br>  }))</pre> | <pre>{<br>  "production": {<br>    "data_bucket": {<br>      "name": "demo-ivs"<br>    },<br>    "k8s_namespace": "ivs",<br>    "opensearch": {<br>      "enable": false<br>    },<br>    "raw_data_bucket": {<br>      "name": "demo-ivs-rawdata"<br>    }<br>  }<br>}</pre> | no |
| <a name="input_kubernetesVersion"></a> [kubernetesVersion](#input\_kubernetesVersion) | The kubernetes version of the EKS cluster. | `string` | `"1.32"` | no |
| <a name="input_licenseServer"></a> [licenseServer](#input\_licenseServer) | Specifies whether a license server VM will be created. | `bool` | `false` | no |
| <a name="input_linuxExecutionNodeCapacityType"></a> [linuxExecutionNodeCapacityType](#input\_linuxExecutionNodeCapacityType) | The capacity type of the Linux nodes to be used. Defaults to 'ON\_DEMAND' and can be changed to 'SPOT'. Be ware that using spot instances can result in abrupt termination of simulation/validation jobs and corresponding 'error' results. | `string` | `"ON_DEMAND"` | no |
| <a name="input_linuxExecutionNodeCountMax"></a> [linuxExecutionNodeCountMax](#input\_linuxExecutionNodeCountMax) | The maximum number of Linux nodes for the job execution | `number` | `10` | no |
| <a name="input_linuxExecutionNodeCountMin"></a> [linuxExecutionNodeCountMin](#input\_linuxExecutionNodeCountMin) | The minimum number of Linux nodes for the job execution | `number` | `0` | no |
| <a name="input_linuxExecutionNodeDiskSize"></a> [linuxExecutionNodeDiskSize](#input\_linuxExecutionNodeDiskSize) | The disk size in GiB of the nodes for the job execution | `number` | `200` | no |
| <a name="input_linuxExecutionNodeSize"></a> [linuxExecutionNodeSize](#input\_linuxExecutionNodeSize) | The machine size of the Linux nodes for the job execution, user must check the availability of the instance types for the region. The list is ordered by priority where the first instance type gets the highest priority. Instance types must fulfill the following requirements: 64 GB RAM, 16 vCPUs, at least 110 IPs, at least 2 availability zones. | `list(string)` | <pre>[<br>  "m6a.4xlarge",<br>  "m5a.4xlarge",<br>  "m5.4xlarge",<br>  "m6i.4xlarge",<br>  "m4.4xlarge",<br>  "m7i.4xlarge",<br>  "m7a.4xlarge"<br>]</pre> | no |
| <a name="input_linuxNodeCountMax"></a> [linuxNodeCountMax](#input\_linuxNodeCountMax) | The maximum number of Linux nodes for the regular services | `number` | `12` | no |
| <a name="input_linuxNodeCountMin"></a> [linuxNodeCountMin](#input\_linuxNodeCountMin) | The minimum number of Linux nodes for the regular services | `number` | `1` | no |
| <a name="input_linuxNodeDiskSize"></a> [linuxNodeDiskSize](#input\_linuxNodeDiskSize) | The disk size in GiB of the nodes for the regular services | `number` | `200` | no |
| <a name="input_linuxNodeSize"></a> [linuxNodeSize](#input\_linuxNodeSize) | The machine size of the Linux nodes for the regular services, user must check the availability of the instance types for the region. The list is ordered by priority where the first instance type gets the highest priority. Instance types must fulfill the following requirements: 64 GB RAM, 16 vCPUs, at least 110 IPs, at least 2 availability zones. | `list(string)` | <pre>[<br>  "m6a.4xlarge",<br>  "m5a.4xlarge",<br>  "m5.4xlarge",<br>  "m6i.4xlarge",<br>  "m4.4xlarge",<br>  "m7i.4xlarge",<br>  "m7a.4xlarge"<br>]</pre> | no |
| <a name="input_maintainance_duration"></a> [maintainance\_duration](#input\_maintainance\_duration) | How long in hours for the maintenance window. | `number` | `3` | no |
| <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts) | Additional AWS account numbers to add to the aws-auth ConfigMap | `list(string)` | `[]` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of IDs for the private subnets. | `list(any)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of IDs for the public subnets. | `list(any)` | `[]` | no |
| <a name="input_rtMaps_link"></a> [rtMaps\_link](#input\_rtMaps\_link) | Download link for RTMaps license server. | `string` | `"http://dl.intempora.com/RTMaps4/rtmaps_4.9.0_ubuntu1804_x86_64_release.tar.bz2"` | no |
| <a name="input_s3_csi_config"></a> [s3\_csi\_config](#input\_s3\_csi\_config) | Input configuration for AWS EKS add-on aws-mountpoint-s3-csi-driver. By setting key 'enable' to 'true', aws-mountpoint-s3-csi-driver add-on is deployed. Key 'configuration\_values' is used to change add-on configuration. Its content should follow add-on configuration schema (see https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-advanced-configuration/). | <pre>object({<br>    enable = optional(bool, false)<br>    configuration_values = optional(string, <<-YAML<br>node:<br>    tolerateAllTaints: true<br>YAML<br>    )<br>  })</pre> | <pre>{<br>  "enable": false<br>}</pre> | no |
| <a name="input_scan_schedule"></a> [scan\_schedule](#input\_scan\_schedule) | 6-field Cron expression describing the scan maintenance schedule. Must not overlap with variable install\_schedule. | `string` | `"cron(0 0 * * ? *)"` | no |
| <a name="input_simpheraInstances"></a> [simpheraInstances](#input\_simpheraInstances) | A list containing the individual SIMPHERA instances, such as 'staging' and 'production'. | <pre>map(object({<br>    name                         = string<br>    postgresqlApplyImmediately   = bool<br>    postgresqlVersion            = string<br>    postgresqlStorage            = number<br>    postgresqlMaxStorage         = number<br>    db_instance_type_simphera    = string<br>    enable_keycloak              = bool<br>    postgresqlStorageKeycloak    = number<br>    postgresqlMaxStorageKeycloak = number<br>    db_instance_type_keycloak    = string<br>    k8s_namespace                = string<br>    secretname                   = string<br>    enable_backup_service        = bool<br>    backup_retention             = number<br>    enable_deletion_protection   = bool<br><br>  }))</pre> | <pre>{<br>  "production": {<br>    "backup_retention": 35,<br>    "db_instance_type_keycloak": "db.t4g.large",<br>    "db_instance_type_simphera": "db.t4g.large",<br>    "enable_backup_service": true,<br>    "enable_deletion_protection": true,<br>    "enable_keycloak": true,<br>    "k8s_namespace": "simphera",<br>    "name": "production",<br>    "postgresqlApplyImmediately": false,<br>    "postgresqlMaxStorage": 100,<br>    "postgresqlMaxStorageKeycloak": 100,<br>    "postgresqlStorage": 20,<br>    "postgresqlStorageKeycloak": 20,<br>    "postgresqlVersion": "16",<br>    "secretname": "aws-simphera-dev-production"<br>  }<br>}</pre> | no |
| <a name="input_simphera_monitoring_namespace"></a> [simphera\_monitoring\_namespace](#input\_simphera\_monitoring\_namespace) | Name of the K8s namespace used for deploying SIMPHERA monitoring chart | `string` | `"monitoring"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to be added to all resources. | `map(any)` | `{}` | no |
| <a name="input_vpcCidr"></a> [vpcCidr](#input\_vpcCidr) | The CIDR for the virtual private cluster. | `string` | `"10.1.0.0/18"` | no |
| <a name="input_vpcId"></a> [vpcId](#input\_vpcId) | The ID of preconfigured VPC. Change from 'null' to use already existing VPC. | `string` | `null` | no |
| <a name="input_vpcPrivateSubnets"></a> [vpcPrivateSubnets](#input\_vpcPrivateSubnets) | List of CIDRs for the private subnets. | `list(any)` | <pre>[<br>  "10.1.0.0/22",<br>  "10.1.4.0/22",<br>  "10.1.8.0/22"<br>]</pre> | no |
| <a name="input_vpcPublicSubnets"></a> [vpcPublicSubnets](#input\_vpcPublicSubnets) | List of CIDRs for the public subnets. | `list(any)` | <pre>[<br>  "10.1.12.0/22",<br>  "10.1.16.0/22",<br>  "10.1.20.0/22"<br>]</pre> | no |
| <a name="input_windows_execution_node"></a> [windows\_execution\_node](#input\_windows\_execution\_node) | Configuration for Windows node group. 'node\_size' stands for the machine size of the nodes for the job execution, user must check the availability of the instance types for the region. The list is ordered by priority where the first instance type gets the highest priority. 'disk\_size' stands for the disk size in GiB of the nodes for the job execution. 'node\_count\_min' stands for the minimum number of the nodes for the job execution. 'node\_count\_max' stand for the maximum number of the nodes for the job execution | <pre>object({<br>    enable         = bool<br>    node_size      = list(string)<br>    capacity_type  = string<br>    disk_size      = number<br>    node_count_min = number<br>    node_count_max = number<br>  })</pre> | <pre>{<br>  "capacity_type": "ON_DEMAND",<br>  "disk_size": 200,<br>  "enable": false,<br>  "node_count_max": 2,<br>  "node_count_min": 0,<br>  "node_size": [<br>    "m6a.4xlarge",<br>    "m5a.4xlarge",<br>    "m5.4xlarge",<br>    "m6i.4xlarge",<br>    "m4.4xlarge",<br>    "m7i.4xlarge",<br>    "m7a.4xlarge"<br>  ]<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account id used for creating resources. |
| <a name="output_backup_vaults"></a> [backup\_vaults](#output\_backup\_vaults) | Backups vaults from all dSPACE cloud products managed by terraform. |
| <a name="output_database_endpoints"></a> [database\_endpoints](#output\_database\_endpoints) | Identifiers of the SIMPHERA and Keycloak databases from all SIMPHERA instances. |
| <a name="output_database_identifiers"></a> [database\_identifiers](#output\_database\_identifiers) | Identifiers of the SIMPHERA and Keycloak databases from all SIMPHERA instances. |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | Amazon EKS Cluster Name |
| <a name="output_ivs_buckets_service_accounts"></a> [ivs\_buckets\_service\_accounts](#output\_ivs\_buckets\_service\_accounts) | List of K8s service account names with access to the IVS buckets |
| <a name="output_ivs_node_groups_roles"></a> [ivs\_node\_groups\_roles](#output\_ivs\_node\_groups\_roles) | n/a |
| <a name="output_opensearch_domain_endpoints"></a> [opensearch\_domain\_endpoints](#output\_opensearch\_domain\_endpoints) | List of OpenSearch Domains endpoints of IVS instances |
| <a name="output_pullthrough_cache_prefix"></a> [pullthrough\_cache\_prefix](#output\_pullthrough\_cache\_prefix) | n/a |
| <a name="output_s3_buckets"></a> [s3\_buckets](#output\_s3\_buckets) | S3 buckets managed by terraform. |
<!-- END_TF_DOCS -->
