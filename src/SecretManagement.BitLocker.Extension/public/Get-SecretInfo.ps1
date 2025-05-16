function Get-SecretInfo {
    [CmdletBinding()]
    param (
        [string] $Filter,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $results = @()

    $searchFilter = if (-not[string]::IsNullOrEmpty($Filter)) {
        'objectClass -eq "computer" -and name -like "' + $Filter + '"'
    }
    else {
        '*'
    }

    $computer = Get-ADComputer -Filter $searchFilter

    foreach ($_computer in $computer) {
        $results += Get-ADComputerBitLockerRecoveryPassword -Name $_computer.Name
    }

    $results | ForEach-Object {
        $metadata = [Ordered]@{
            'Id' = $PSItem.Id
            'Domain' = $PSItem.Domain
            'WhenCreated' = $PSItem.WhenCreated
            'DNSHostName' = $PSItem.DNSHostName
        }

        return @(,[Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
            $PSItem.Name,
            [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential,
            $VaultName,
            $metadata))
    } 
}