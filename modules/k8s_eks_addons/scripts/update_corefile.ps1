param (
    [Parameter(Mandatory = $true)][string]$cluster_name,
    [Parameter(Mandatory = $true)][string]$simphera_fqdn,
    [Parameter(Mandatory = $true)][string]$kubeconfig
)


$DNSCONFIG = kubectl get configmap coredns -n kube-system --kubeconfig $kubeconfig -o=jsonpath='{.data.Corefile}'
$DNSCONFIG_STR = $DNSCONFIG | Out-String
Write-Host "$DNSCONFIG_STR"
$IP = kubectl get service ingress-nginx-controller -n nginx --kubeconfig $kubeconfig -o=jsonpath='{.spec.clusterIP}'

$HASHOSTS = $DNSCONFIG_STR -Match "hosts\s*{"
if (!$HASHOSTS) {

    $HOSTS = @"
    hosts {
      $IP $simphera_fqdn
      fallthrough
    }
"@
    Write-Host "Adding host to coredns config."
    $INDEX = $DNSCONFIG_STR.LastIndexOf('}')
    $DNSCONFIG_STR = $DNSCONFIG_STR.Substring(0, $INDEX) + $HOSTS + "`n}"
    Write-Host "DNSCONFIG_STR: $DNSCONFIG_STR"

    kubectl create configmap coredns -n kube-system -o yaml --dry-run=client --kubeconfig $kubeconfig --from-literal=Corefile=$DNSCONFIG_STR
    | kubectl apply --kubeconfig $kubeconfig -f -
}
else {
    $DNSCONFIG_STR_ARRAY = $DNSCONFIG_STR -split "hosts"
    $DNSCONFIG_SUB_STR = $DNSCONFIG_STR_ARRAY[0]
    $DNSCONFIG_HOST = $DNSCONFIG_STR_ARRAY[1]

    $start_index = $DNSCONFIG_STR.lastIndexOf("{")
    $end_index = $DNSCONFIG_STR.IndexOf($IP)
    $len_index = $end_index - $start_index
    $DNSCONFIG_WS_STR = $DNSCONFIG_STR.Substring($start_index, $len_index)

    $WhiteSpaceCount = ($DNSCONFIG_WS_STR -split '\s').Length - 3

    for ($i = 0; $i -lt $WhiteSpaceCount; $i++) {
        $White_Spaces += " "
    }

    $NEW_HOST = $IP + " " + $simphera_fqdn + "`n" + $White_Spaces + "fallthrough"
    #$NEW_HOST = $IP + " " + $simphera_fqdn + "`n" + "      fallthrough"

    $HASHOST = $DNSCONFIG_STR -Match "$IP $simphera_fqdn"
    Write-Host("HASHOST: $HASHOST")

    if (!$HASHOST) {
        Write-Host "Adding host to coredns config."
        $DNSCONFIG_HOST = $DNSCONFIG_HOST -replace 'fallthrough', $NEW_HOST
        $DNSCONFIG_STR = $DNSCONFIG_SUB_STR + "hosts" + $DNSCONFIG_HOST
        Write-Host "DNSCONFIG_STR: $DNSCONFIG_STR"

        kubectl create configmap coredns -n kube-system -o yaml --dry-run=client --kubeconfig $kubeconfig --from-literal=Corefile=$DNSCONFIG_STR
        | kubectl apply --kubeconfig $kubeconfig -f -
    }
    else {
        Write-Host "CoreDNS configmap already has host configuration."
    }
}
