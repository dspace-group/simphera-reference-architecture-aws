param (
    [Parameter(Mandatory = $true)][string]$cluster_name,
    [Parameter(Mandatory = $true)][string[]]$simphera_fqdns,
    [Parameter(Mandatory = $true)][string]$kubeconfig_encoded_content
)
$ErrorActionPreference = 'Stop'

$kubeconfig = New-TemporaryFile
[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($kubeconfig_encoded_content)) > $kubeconfig

$DNSCONFIG_STR = kubectl get configmap coredns -n kube-system --kubeconfig $kubeconfig -o=jsonpath='{.data.Corefile}' | Out-String
$IP = kubectl get service ingress-nginx-controller -n nginx --kubeconfig $kubeconfig -o=jsonpath='{.spec.clusterIP}'

$base_indent = " " * 4
$entry_indent = " " * 2

$hosts_block = "hosts {`n"
foreach ($entry in $simphera_fqdns) {
    $hosts_block += $base_indent + $entry_indent + $IP + " " + $entry + "`n"
}
$hosts_block += $base_indent + $entry_indent + "fallthrough" + "`n" + $base_indent + "}"

$has_hosts_index = $DNSCONFIG_STR.IndexOf("hosts {")
$end_index = $DNSCONFIG_STR.LastIndexOf('}')
$INDEX = ($has_hosts_index -gt 0) ? $has_hosts_index : $end_index
if ($has_hosts_index -gt 0) {
    $DNSCONFIG_STR = $DNSCONFIG_STR.Substring(0, $has_hosts_index) + $hosts_block + "`n}"
}
else {
    $DNSCONFIG_STR = $DNSCONFIG_STR.Substring(0, $end_index) + $base_indent + $hosts_block + "`n}"
}

kubectl create configmap coredns -n kube-system -o yaml --dry-run=client --kubeconfig $kubeconfig --from-literal=Corefile=$DNSCONFIG_STR | kubectl apply --kubeconfig $kubeconfig -f -
