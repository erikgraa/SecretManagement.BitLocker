function Get-Secret {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    try {
        $secret = Get-ADComputerBitlockerRecoveryPassword -Name $Name | Select-Object -ExpandProperty RecoveryPassword | ConvertTo-SecureString -AsPlainText -Force

        [System.Management.Automation.PSCredential]::new($Name, $secret)
    }
    catch { 
        Write-Debug ("Could not find BitLocker recovery password for computer '{0}'" -f $Name)
    }
}