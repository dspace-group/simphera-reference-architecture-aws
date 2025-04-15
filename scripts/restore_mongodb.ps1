<#
.SYNOPSIS
    Restores a mongodb from a EBS snapshot.
.DESCRIPTION
    Restore EC2 EBS volume from backup vault EBS volume snapshot.
    Add copy tags to newly created volume.
    Find all PersistentVolume of $ivs_release_name-mongodb-0.
    Scale down StatefulSets of $ivs_release_name-mongodb and $ivs_release_name-mongodb-arbiter,
    Delete PersistentVolumeClaims datadir-$ivs_release_name-mongodb-0 and datadir-$ivs_release_name-mongodb-1.
    Create new PersistentVolume from newly created EBS volume.
    Create new PersistentVolumeClaim datadir-$ivs_release_name-mongodb-0 using the new PersistentVolume.
    Scale up StatefulSets to the original number of replicas.
.PARAMETER clusterid
    The EKS cluster id where to update PersistentVolumes and PersistentVolumeClaims.
.PARAMETER snapshot_arn
     Snapshot ARNs to restore.
.PARAMETER rolearn
    IAM role which has the policy AWSBackupServiceRolePolicyForRestores attached and is used for restoring.
.PARAMETER profile
    AWS profile name in which EKS is deployed.
.PARAMETER region
    AWS region name in which EKS is deployed.
.PARAMETER kubeconfig
    Path to the kubeconfig for clusterid.
.PARAMETER namespace
    K8s namespace where ivs-mongodb is deployed.
.PARAMETER ivs_release_name
    Chart's release name of the IVS.
.PARAMETER retain_pv
    Flag used if old PersistentVolume needs to be retain. If not set, old PV is deleted.
.EXAMPLE
    ./restore_mongodb.ps1 -clusterid "aws-preprod-dev-eks" -snapshot_arn "arn:aws:ec2:eu-central-1::snapshot/snap-09ff08e544900c72b" -rolearn "arn:aws:iam::012345678901:role/restorerole" -profile "profile-1" -region "eu-central-1" -kubeconfig "C:\Users\user1\.kube\clusterid\config" -namespace "ivs" -ivs_release_name "ivs"
#>
param(
    [parameter(Mandatory = $true)][string] $clusterid,
    [parameter(Mandatory = $true)][string] $snapshot_arn,
    [parameter(Mandatory = $true)][string] $rolearn,
    [parameter(Mandatory = $true)][string] $profile,
    [parameter(Mandatory = $true)][string] $region,
    [parameter(Mandatory = $true)][string] $kubeconfig,
    [parameter(Mandatory = $true)][string] $namespace,
    [parameter(Mandatory = $true)][string] $ivs_release_name,
    [switch] $retain_pv
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$aws_profile_flags = @("--profile", $profile, "--region", $region)

function ReplaceValueSubstring {
    param (
        $elements,
        $old_value,
        $new_value
    )
    Write-Host "Replacing $old_value with $new_value"
    $new_elements = @()
    foreach ($el in $elements) {
        $key = $el.Key
        $value = $el.Value -replace $old_value, $new_value
        $new_elements += @{"Key" = $key ; "Value" = $value }
    }
    $elements_json_list = @($new_elements) | ConvertTo-Json
    $elements_string = @"
$elements_json_list
"@
    $elements_string = $elements_string.Trim()
    return $elements_string
}

function UpdateNewVolumeTags {
    param(
        $new_volume_id,
        $old_volume_id,
        $new_pv_name,
        $old_pv_name,
        $aws_profile_flags
    )
    $volume_tags = aws ec2 describe-tags @aws_profile_flags --filters "Name=resource-id, Values=$old_volume_id" | ConvertFrom-Json
    $new_tags = ReplaceValueSubstring -elements $volume_tags.Tags -old_value $old_pv_name -new_value $new_pv_name
    aws ec2 create-tags --resources "$new_volume_id" @aws_profile_flags --tags $new_tags
    Write-Host "Tags added to $new_volume_id"
}

function WaitRestore {
    param(
        $restore_job_id,
        $aws_profile_flags
    )
    $status = ""
    Do {
        Start-Sleep -Seconds 10
        $temp_restore_job_object = aws backup describe-restore-job @aws_profile_flags --restore-job-id $restore_job_id | ConvertFrom-Json
        $status = $temp_restore_job_object.Status
    } while ( $status -ne "Completed")
    Write-Host "Restore job finished."
    $volume_id = ($temp_restore_job_object.CreatedResourceArn -split "volume/")[1]
    Write-Host "New volumeid: $volume_id"
    return $volume_id
}

function RestoreVolume {
    param(
        $snapshort_arn,
        $old_volume_id,
        $aws_profile_flags,
        $rolearn
    )
    $snapshot_id = ($snapshot_arn -split "snapshot/")[1]
    $snapshot = aws ec2 describe-snapshots --snapshot-ids $snapshot_id @aws_profile_flags | ConvertFrom-Json
    $snapshot_volume_id = $snapshot.Snapshots.VolumeId
    Write-Host "Snapshots VolumeID: $snapshot_volume_id"
    $volumes = aws ec2 describe-volumes --volume-ids $old_volume_id @aws_profile_flags | ConvertFrom-Json

    $device = $volumes.Volumes[0].Attachments[0].Device
    Write-Host "Device: $device"
    $instance_id = $volumes.Volumes[0].Attachments[0].InstanceId
    Write-Host "Instance: $instance_id"
    $availabilityzone = $volumes.Volumes[0].AvailabilityZone
    Write-Host "AvailabilityZone: $availabilityzone"
    $metadata = @"
    {"encrypted":"false","volumeId":"$old_volume_id","availabilityZone":"$availabilityzone"}
"@
    $metadata = $metadata.Trim()
    Write-Host "Starting RestoreJob"
    $restore_job = aws backup start-restore-job --recovery-point-arn "$snapshot_arn" --iam-role-arn "$rolearn" @aws_profile_flags --metadata $metadata | ConvertFrom-Json

    $restore_job_id = $restore_job.RestoreJobId
    $new_volume_id = WaitRestore $restore_job_id $aws_profile_flags
    return $new_volume_id, $availabilityzone
}

function GetPVByClaimRef {
    param(
        $claim_ref,
        $namespace,
        $kubeconfig
    )
    $pvs = kubectl get pv -o json --kubeconfig $kubeconfig | ConvertFrom-Json
    $pv = ""
    foreach ($each in $pvs.items) {
        if ($each.spec.claimRef.name.EndsWith($claim_ref) -And $each.spec.claimRef.namespace.EndsWith($namespace)) {
            $pv = $each
            break
        }
    }
    return $pv
}

function CreatePersistentVolume {
    param(
        $old_pv,
        $pv_name,
        $storage,
        $volume_id,
        $availability_zone,
        $kubeconfig
    )
    Write-Host "Creating PV $pv_name"
    $manifest = @"
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $pv_name
spec:
  storageClassName: gp2
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: $storage
  persistentVolumeReclaimPolicy: Delete
  awsElasticBlockStore:
    fsType: ext4
    volumeID: "aws://$availability_zone/$volume_id"
"@
    $manifest | kubectl apply --kubeconfig $kubeconfig -f -
    Write-Host "PV $pv_name created"
    Write-Host "Patch PV"
    $patchJson = @{
        metadata = @{
            labels      = $old_pv.metadata.labels
            annotations = $old_pv.metadata.annotations
            finalizers  = $old_pv.metadata.finalizers
        }
    } | ConvertTo-Json -Compress
    kubectl patch pv $pv_name --type strategic --kubeconfig $kubeconfig -p $patchJson
}

function PrepareNewPVC {
    param(
        $pvc_name,
        $new_pv_name,
        $namespace,
        $kubeconfig
    )
    Write-Host "Prepare new PVC"
    $pvc = kubectl get pvc $pvc_name -n $namespace -o json --kubeconfig $kubeconfig | ConvertFrom-Json
    $pvc.metadata.PSObject.Properties.Remove('annotations')
    $pvc.metadata.PSObject.Properties.Remove('creationTimestamp')
    $pvc.metadata.PSObject.Properties.Remove('managedFields')
    $pvc.PSObject.Properties.Remove('status')
    $pvc.spec.volumeName = $new_pv_name
    return $pvc
}

function DownscaleResources {
    param(
        $namespace,
        $kubeconfig,
        $ivs_release_name
    )
    Write-Host "Downscaling mongodb and arbiter pods"
    kubectl scale statefulsets "$ivs_release_name-mongodb" -n $namespace --replicas=0 --kubeconfig $kubeconfig
    kubectl scale statefulsets "$ivs_release_name-mongodb-arbiter" -n $namespace --replicas=0 --kubeconfig $kubeconfig
    Start-Sleep -Seconds 60
    Write-Host "Downscaling done"
}

function DeletePVCs {
    param(
        $namespace,
        $kubeconfig,
        $retain_policy = "Delete",
        $ivs_release_name
    )
    Write-Host "Delete PVCs"
    kubectl delete pvc "datadir-$ivs_release_name-mongodb-0" -n $namespace --kubeconfig $kubeconfig --wait=true
    kubectl delete pvc "datadir-$ivs_release_name-mongodb-1" -n $namespace --kubeconfig $kubeconfig --wait=true
    Write-Host "Delete PVCs done"
    Start-Sleep -Seconds 60
}

function WaitUpscale {
    param(
        $statefulset_name,
        $replicas_num,
        $namespace,
        $kubeconfig
    )
    $available_replicas = 0
    do {
        $statefulsets = kubectl get statefulsets $statefulset_name -n $namespace --kubeconfig $kubeconfig -o json | ConvertFrom-Json
        $available_replicas = $statefulsets.status.availableReplicas
        Write-Host "Current available replicas:" $available_replicas
    } while ($available_replicas -ne $replicas_num)
}

function UpscaleResources {
    param(
        $mongodb_replicas_num,
        $namespace,
        $kubeconfig,
        $ivs_release_name
    )
    Write-Host "Upscale resources"
    kubectl scale statefulsets "$ivs_release_name-mongodb" -n $namespace --replicas=$mongodb_replicas_num --kubeconfig $kubeconfig
    kubectl scale statefulsets "$ivs_release_name-mongodb-arbiter" -n $namespace --replicas=1 --kubeconfig $kubeconfig
    WaitUpscale -statefulset_name "$ivs_release_name-mongodb" -replicas_num $mongodb_replicas_num -namespace $namespace -kubeconfig $kubeconfig
    WaitUpscale -statefulset_name "$ivs_release_name-mongodb-arbiter" -replicas_num 1 -namespace $namespace -kubeconfig $kubeconfig
    Write-Host "Upscale resources done"
}

Write-Host "Processing $snapshot_arn"

$old_pv = GetPVByClaimRef -claim_ref "datadir-$ivs_release_name-mongodb-0" -namespace $namespace -kubeconfig $kubeconfig
if ($retain_pv) {
    Write-Host "Patch $pv_name's 'persistentVolumeReclaimPolicy' to 'Retain'"
    kubectl patch pv $pv_name -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}' --kubeconfig $kubeconfig
}
$old_volume_id = ($old_pv.spec.awsElasticBlockStore.volumeID -split "/")[-1]
$new_volume_id, $availability_zone = RestoreVolume -snapshort_arn $snapshot_arn -aws_profile_flags $aws_profile_flags -rolearn $rolearn -old_volume_id $old_volume_id
$uuid = New-Guid
$new_pv_name = "pvc-$uuid"

UpdateNewVolumeTags -new_volume_id $new_volume_id -old_volume_id $old_volume_id -new_pv_name $new_pv_name -old_pv_name $old_pv.metadata.name -aws_profile_flags $aws_profile_flags
CreatePersistentVolume -old_pv $old_pv -pv_name $new_pv_name -storage $old_pv.spec.capacity.storage -volume_id $new_volume_id -availability_zone $availability_zone -kubeconfig $kubeconfig

$pvc = PrepareNewPVC -pvc_name "datadir-$ivs_release_name-mongodb-0" -new_pv_name $new_pv_name -namespace $namespace -kubeconfig $kubeconfig
$mongodb_replicas_num = kubectl get statefulsets "$ivs_release_name-mongodb" -n $namespace -o jsonpath='{.spec.replicas}' --kubeconfig $kubeconfig
DownscaleResources -namespace $namespace -kubeconfig $kubeconfig -ivs_release_name $ivs_release_name
DeletePVCs -namespace $namespace -kubeconfig $kubeconfig -ivs_release_name $ivs_release_name

Write-Host "Create new PVC"
$new_pvc_json = $pvc | ConvertTo-Json -Depth 100
$new_pvc_json | kubectl apply --kubeconfig $kubeconfig -f -
Write-Host "PVC created"

UpscaleResources -mongodb_replicas_num $mongodb_replicas_num -namespace $namespace -kubeconfig $kubeconfig -ivs_release_name $ivs_release_name

Write-Host "Deleting backend pod"
kubectl delete pod -l "app.kubernetes.io/component=backend" -n $namespace --kubeconfig $kubeconfig --wait
Write-Host "backend pod deleted"
